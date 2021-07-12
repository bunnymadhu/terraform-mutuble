resource "aws_spot_instance_request" "mongodb" {
  ami                                         = data.aws_ami.centos7.id
  spot_price                               = "0.0032"
  instance_type                          = "t3.micro"
  vpc_security_group_ids            = [aws_security_group.allow_mongodb.id]
  subnet_id                                = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS[1]
  wait_for_fulfillment                   = true

  tags                                        = {
    Name                                    = "mongodb-${var.ENV}"
    Environment                           = var.ENV
  }
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

resource "null_resource" "ansible_mongo" {
  provisioner "local-exec" {
    command                         = "sleep 30"
  }

  provisioner "remote-exec" {
    connection {
      host                             = aws_spot_instance_request.mongodb.private_ip
      user                            = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_USER"]
      password                     = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_PASS"]
    }

    inline = [
      "sudo yum install ansible -y",
      "sudo yum remove ansible -y",
      "sudo rm -rf /usr/lib/python2.7/site-packages/ansible*",
      "sudo yum remove python-pip -y",
      "sudo cd /usr/local/src",
      "sudo wget https://bootstrap.pypa.io/pip/2.7/get-pip.py",
      "sudo python get-pip.py",
      "sudo pip3 install ansible==4.1.0",
      "ansible-pull -i localhost, -U https://github.com/bunnymadhu/ansible.git roboshop-pull.yml -e COMPONENT=mongodb"

    ]

  }
}

## in AWS  there is secretsmanager which stores only secrets...so we can give dev_ENV as SSH_user name(centos) and SSH_password(Devops321)