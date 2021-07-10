//resource "aws_spot_instance_request" "mongodb" {
//  count                                      = length(var.COMPONENTS)
//  ami                                         = "ami-059e6ca6474628ef0"
//  spot_price                               = "0.0036"
//  instance_type                          = "t2.micro"
//  vpc_security_group_ids            = ["sg-01d1633aaca167f8e"]
//
//  tags                                        = {
//    Name                                    = element(var.COMPONENTS, count.index)
//  }
//}

## u can find the "aws spot instance terraform" -- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request to launch instances by using spot request..
