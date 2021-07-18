resource "aws_spot_instance_request" "instances" {
  count                                      = var.INSTANCE_COUNT
  ami                                         = data.aws_ami.centos7.id
  spot_price                               = var.SPOT_PRICE
  instance_type                          = var.INSTANCE_TYPE
  vpc_security_group_ids            = [aws_security_group.allow_ec2.id]
  subnet_id                                = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS, count.index)
  wait_for_fulfillment                    = true

  tags                                        = {
    Name                                    = "${var.COMPONENT}-${var.ENV}"
    Environment                          = var.ENV
  }
}

## it is in terraform_vpc_aws_Security group
resource "aws_security_group" "allow_ec2" {
  name                                      = "allow_${var.COMPONENT}"
  description                              = "allow_${var.COMPONENT}"
  vpc_id                                     = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description                           = "SSH"
    from_port                             = 22
    to_port                                 = 22
    protocol                               = "tcp"
    cidr_blocks                          = [data.terraform_remote_state.vpc.outputs.VPC_CIDR, data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR]
  }

  ## for SSH we need to allow these two networks(VPC_CIDR,DEFAULT_VPC_CIDR)....

  ingress {
    description                           = "HTTP"
    from_port                             = var.PORT
    to_port                                 = var.PORT
    protocol                               = "tcp"
    cidr_blocks                          = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  ## tcp----Transmission Control Protocol----TCP stands for Transmission Control Protocol a communications standard that enables application programs and computing devices to                                                                       exchange messages over a network. It is designed to send packets across the internet and ensure the successful delivery of data and                                                                        messages over networks..

  egress {
    from_port                           = 0
    to_port                               = 0
    protocol                             = "-1"
    cidr_blocks                        = ["0.0.0.0/0"]
    ipv6_cidr_blocks                = ["::/0"]
  }

  tags = {
    Name                               = "allow_${var.COMPONENT}"
  }
}

resource "null_resource" "wait" {
  triggers                           = {
    abc                               = timestamp()
  }
  provisioner "local-exec" {
    command                      = "sleep 30"
  }
}

resource "null_resource" "ansible-apply" {
  count                             = var.INSTANCE_COUNT
  depends_on                   = [null_resource.wait]

  provisioner "remote-exec" {
    connection {
      host                          = element(aws_spot_instance_request.instances.*.private_ip, count.index)
      user                          = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_USER"]
      password                  = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_PASSWORD"]
    }

    inline = [
      "sudo yum install python3-pip -y",
      "sudo pip3 install pip --upgrade",
      "sudo pip3 install ansible==4.1.0",
      "ansible-pull -i localhost, -U https://github.com/bunnymadhu/ansible.git roboshop-pull.yml -e COMPONENT=${var.COMPONENT}"

    ]

  }
}

## it is in aws_targetgroup_terraform

resource "aws_lb_target_group" "target-group" {
  name                           = "${var.COMPONENT}-${var.ENV}"
  port                             = var.PORT
  protocol                       = "HTTP"
  vpc_id                         = data.terraform_remote_state.vpc.outputs.VPC_ID
}

resource "aws_lb_target_group_attachment" "tg-attach" {
  count                          = var.INSTANCE_COUNT
  target_group_arn         = aws_lb_target_group.target-group.arn
  target_id                     = element(aws_spot_instance_request.instances.*.spot_instance_id, count.index )
  port                            = var.PORT
}

## it is in aws_targetgroup_terraform_ Elastic Load Balancing v2 (ALB/NLB)_aws_lb_listener_rule

resource "aws_lb_listener_rule" "component-rule" {
  listener_arn              = var.LISTENER_ARN
  priority                     = var.LB_RULE_WEIGHT

  action {
    type                       = "forward"
    target_group_arn    = aws_lb_target_group.target-group.arn
  }

  condition {
    host_header {
      values                  = ["${var.COMPONENT}-${var.ENV}.roboshop.internal"]
    }
  }
}

## if any request is coming as catalogue-dev.roboshop.internal,,so send targets to this catalogue-dev...So we need to vreate DNS record for catalogue-dev right we need to create dns record

##it is in aws_route53_aws_route53_record

resource "aws_route53_record" "component-record" {
  zone_id                = data.terraform_remote_state.vpc.outputs.HOSTED_ZONE_ID
  name                   = "${var.COMPONENT}-${var.ENV}.roboshop.internal"
  type                     = "CNAME"
  ttl                         = "300"
  records                = [var.LB_DNSNAME]
}

