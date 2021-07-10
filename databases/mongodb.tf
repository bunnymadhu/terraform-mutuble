//resource "aws_spot_instance_request" "mongodb" {
//  ami                                         = data.aws_ami.centos7.id
//  spot_price                               = "0.0036"
//  instance_type                          = "t2.micro"
//  vpc_security_group_ids            = ["sg-01d1633aaca167f8e"]
//
//  tags                                        = {
//    Name                                    = element(var.COMPONENTS, count.index)
//  }
//}
//
//## u can find the "aws spot instance terraform" -- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request to launch instances by using spot request..
//
//
//resource "aws_security_group" "allow_mongodb" {
//  name                                      = "allow_mongodb"
//  description                              = "AllowMongoDB"
//  vpc_id                                     = aws_vpc.main.id
//
//  ingress {
//    description                           = "TLS from VPC"
//    from_port                             = 443
//    to_port                                 = 443
//    protocol                               = "tcp"
//    cidr_blocks                          = [aws_vpc.main.cidr_block]
//    ipv6_cidr_blocks                  = [aws_vpc.main.ipv6_cidr_block]
//  }
//
//  egress {
//    from_port                           = 0
//    to_port                               = 0
//    protocol                             = "-1"
//    cidr_blocks                        = ["0.0.0.0/0"]
//    ipv6_cidr_blocks                = ["::/0"]
//  }
//
//  tags = {
//    Name                               = "allow_tls"
//  }
//}