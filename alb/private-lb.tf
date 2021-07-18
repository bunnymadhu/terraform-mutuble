resource "aws_lb" "private" {
  name                                       = "alb-private-${var.ENV}"
  internal                                    = true
  load_balancer_type                  = "application"
  security_groups                       = [aws_security_group.allow_private_lb.id]
  subnets                                   = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS
    tags = {
      Environment                        =  var.ENV
      Name                                  = "alb-private-${var.ENV}"
  }
}

## it is in terraform_vpc_aws_Security group
resource "aws_security_group" "allow_private_lb" {
  name                                      = "allow_private_lb"
  description                              = "AllowPrivateLB"
  vpc_id                                     = data.terraform_remote_state.vpc.outputs.VPC_ID

## see data.tf for vpc_id

  ingress {
    description                           = "HTTP"
    from_port                             = 80
    to_port                                 = 80
    protocol                               = "tcp"
    cidr_blocks                          = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  ## for MONGODB we need to allow ONLY internal to this VPC not needed externalother vpc's...(VPC_CIDR)....
  ## tcp----Transmission Control Protocol----TCP stands for Transmission Control Protocol a communications standard that enables application programs and computing devices to                                                                       exchange messages over a network. It is designed to send packets across the internet and ensure the successful delivery of data and                                                                        messages over networks..

  egress {
    from_port                           = 0
    to_port                               = 0
    protocol                             = "-1"
    cidr_blocks                        = ["0.0.0.0/0"]
    ipv6_cidr_blocks                = ["::/0"]
  }

  tags = {
    Name                               = "AllowPrivateLB"
  }
}


## see aws_Elastic Load Balancing v2 (ALB/NLB)_aws_lb_listener--fixed response

resource "aws_lb_listener" "common" {
  load_balancer_arn             = aws_lb.private.arn
  port                                  = "80"
  protocol                            = "HTTP"

  default_action {
    type                               = "fixed-response"

    fixed_response {
      content_type                = "text/plain"
      message_body            = "OK"
      status_code                 = "200"
    }
  }
}
