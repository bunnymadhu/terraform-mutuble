resource "aws_route53_zone_association" "secondary" {
  zone_id = var.HOSTED_ZONE_ID
  vpc_id  = aws_vpc.main.id
}


## in route53,there is edit hosted zone,in that vpc credentials are there,in that we have update thru automation thats y we have to update it
## go to in chrome VPCs to associate with the hosted zone terraform in that copy from the above Resource..