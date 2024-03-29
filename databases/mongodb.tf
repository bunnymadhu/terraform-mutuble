resource "aws_spot_instance_request" "mongodb" {
  ami                                         = data.aws_ami.centos7.id
  spot_price                               = "0.0032"
  instance_type                          = "t3.micro"
  vpc_security_group_ids            = [aws_security_group.allow_mongodb.id]
  subnet_id                                = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS[1]
  wait_for_fulfillment                    = true

  tags                                        = {
    Name                                    = "mongodb-${var.ENV}"
    Environment                          = var.ENV
  }
}

## we can give time here for to create instances at that particular names...means var.COMPONENTS

resource "aws_ec2_tag" "mongo" {
  resource_id                             = aws_spot_instance_request.mongodb.spot_instance_id
  key                                         = "Name"
  value                                       = "mongodb-${var.ENV}"
}

## u can find the "aws spot instance terraform" -- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request to launch instances by using spot request..
## it is in terraform_vpc_aws_Security group
resource "aws_security_group" "allow_mongodb" {
  name                                      = "allow_mongodb"
  description                              = "AllowMongoDB"
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
    description                           = "MONGODB"
    from_port                             = 27017
    to_port                                 = 27017
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
    Name                               = "AllowMongoDB"
  }
}
## if  we give this data,,it allows in AWS security groups and  it will shows  inbound rules as allow_mongodb...

## so finally we can push above data in AWS there is  one instance created in the name mongodb,
## so we can connect to that instnace load the mongodb with the help of ansible because in terraform we can thru ansiblke right...

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command                      = "sleep 30"
  }
}

resource "null_resource" "ansible-mongo" {
  depends_on                   = [null_resource.wait]

  provisioner "remote-exec" {
    connection {
      host                          = aws_spot_instance_request.mongodb.private_ip
      user                          = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_USER"]
      password                  = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_PASSWORD"]
    }

    inline = [
      "sudo yum install python3-pip -y",
      "sudo pip3 install pip --upgrade",
      "sudo pip3 install ansible==4.1.0",
      "ansible-pull -i localhost, -U https://github.com/bunnymadhu/ansible.git roboshop-pull.yml -e COMPONENT=mongodb"

    ]

  }
}

## we creted one dns record in instances/ec2.tf in that record copy and paste here and update as mongodb

resource "aws_route53_record" "mongodb-record" {
  zone_id                = data.terraform_remote_state.vpc.outputs.HOSTED_ZONE_ID
  name                   = "mongodb-${var.ENV}.roboshop.internal"
  type                     = "A"
  ttl                         = "300"
  records                = [aws_spot_instance_request.mongodb.private_ip]
}


## in AWS  there is secretsmanager which stores only secrets...so we can give dev_ENV as SSH_user name(centos) and SSH_password(Devops321)