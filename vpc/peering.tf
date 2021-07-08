resource "aws_vpc_peering_connection" "peer-connection" {
  peer_vpc_id                  = aws_vpc.main.id
  vpc_id                          = var.DEFAULT_VPC_ID
  auto_accept                 = true
}

# peering connections is useful to connect to one vpc to another vpc....
# auto_accept   = true is only accept the same account (owner account), if we goes beyond the another account it will nt accept