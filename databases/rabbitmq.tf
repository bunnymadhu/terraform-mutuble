resource "aws_mq_broker" "rabbitmq" {
  broker_name                          = "rabbitmq-${var.ENV}"
  deployment_mode                   = "SINGLE_INSTANCE"

  engine_type                           = "RabbitMQ"
  engine_version                       = "3.8.11"
  host_instance_type                 = "mq.t3.micro"
  security_groups                     = [aws_security_group.allow_rabbitmql.id]
  subnet_ids                             = [data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS[0]]


  user {
    username                            = "roboshop"
    password                             = "roboshop1234"
  }
}

resource "aws_security_group" "allow_rabbitmql" {
  name                                  = "allow_rabbitmq"
  description                          = "AllowRabbitMQ"
  vpc_id                                = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description                       = "RABBITMQ"
    from_port                         = 5672
    to_port                             = 5672
    protocol                           = "tcp"
    cidr_blocks                      = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  ## for MONGODB we need to allow ONLY internal to this VPC not needed externalother vpc's...(VPC_CIDR)....
  ## tcp----Transmission Control Protocol----TCP stands for Transmission Control Protocol a communications standard that enables application programs and computing devices to                                                                       exchange messages over a network. It is designed to send packets across the internet and ensure the successful delivery of data and                                                                        messages over networks..

  egress {
    from_port                       = 0
    to_port                           = 0
    protocol                         = "-1"
    cidr_blocks                    = ["0.0.0.0/0"]
    ipv6_cidr_blocks            = ["::/0"]
  }

  tags                                = {
    Name                           = "AllowRabbitMQ"
    Environment                  = var.ENV
  }
}

## we creted one dns record in instances/ec2.tf in that record copy and paste here and update as elastic_cache

resource "aws_route53_record" "rabbitmq-record" {
  zone_id                = data.terraform_remote_state.vpc.outputs.HOSTED_ZONE_ID
  name                   = "rabbitmq-${var.ENV}.roboshop.internal"
  type                     = "CNAME"
  ttl                         = "300"
  records                = [aws_spot_instance_request.mongodb.private_ip]
}


## i want print all the above information by using below output

//output "rabbitmq" {
//  value                             = aws_mq_broker.rabbitmq
//}
