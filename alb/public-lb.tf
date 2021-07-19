resource "aws_lb" "public" {
  name                                       = "alb-public-${var.ENV}"
  internal                                    = false
  load_balancer_type                  = "application"
  security_groups                       = [aws_security_group.allow_public_lb.id]
  subnets                                   = data.terraform_remote_state.vpc.outputs.PUBLIC_SUBNETS
    tags = {
    Environment                          =  var.ENV
    Name                                    = "alb-public-${var.ENV}"
  }
}

## in here here public,so internal is false...in case private,internal is true...
## it is in terraform_vpc_aws_Security group
resource "aws_security_group" "allow_public_lb" {
  name                                      = "allow_public_lb"
  description                              = "AllowPublicLB"
  vpc_id                                     = data.terraform_remote_state.vpc.outputs.VPC_ID

## see data.tf for vpc_id

  ingress {
    description                           = "HTTP"
    from_port                             = 80
    to_port                                 = 80
    protocol                               = "tcp"
    cidr_blocks                          = ["0.0.0.0/0"]
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
    Name                               = "AllowPublicLB"
  }
}

resource "aws_lb_target_group" "frontend-target-group" {
  name                           = "frontend-${var.ENV}"
  port                             = 80
  protocol                       = "HTTP"
  vpc_id                         = data.terraform_remote_state.vpc.outputs.VPC_ID
  health_check {
    path                          = "/"
    port                           = 80
    interval                      = 10
  }
}

## aws_lb_listener terraform in chrome,and why it is public means for frontend all the data comes from the public agent only but whereas other components gets from the information is private agent.

resource "aws_lb_listener" "frontend" {
  load_balancer_arn             = aws_lb.public.arn
  port                                  = "80"
  protocol                            = "HTTP"

  default_action {
    type                               = "forward"
    target_group_arn            = aws_lb_target_group.frontend-target-group.arn
  }
}