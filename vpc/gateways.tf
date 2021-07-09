resource "aws_internet_gateway" "igw" {
  vpc_id                          = aws_vpc.main.id

  tags = {
    Name                         = "igw"
  }
}
## igw--internet gateway---------igw is the public subnets and NATway is the private subnets...NATway is the chargable not free...
## rt-route-table
## eip--elastic ip

## public and private Natgateway in aws--- A public subnet is a subnet that's associated with a route table that has a route to an internet gateway. A private subnet with a size /24 IPv4                                                                CIDR block (example: 10.0. ... This connects the VPC to the internet and to other AWS services. Instances with private IPv4 addresses in the                                                              subnet range (examples: 10.0.

## public gateway--Public – (Default) Instances in private subnets can connect to the internet through a public NAT gateway, but cannot receive unsolicited inbound connections from                                            the internet. You create a public NAT gateway in a public subnet and must associate an elastic IP address with the NAT gateway at creation. You route                                               traffic from the NAT gateway to the internet gateway for the VPC. Alternatively, you can use a public NAT gateway to connect to other VPCs or your                                                   on-premises network. In this case, you route traffic from the NAT gateway through a transit gateway or a virtual private gateway.

## private gateway--Private – Instances in private subnets can connect to other VPCs or your on-premises network through a private NAT gateway. You can route traffic from the NAT                                            gateway through a transit gateway or a virtual private gateway. You cannot associate an elastic IP address with a private NAT gateway. You can attach an                                           internet gateway to a VPC with a private NAT gateway, but if you route traffic from the private NAT gateway to the internet gateway, the internet gateway                                             drops the traffic.

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id                    = aws_eip.nat.id
  subnet_id                        = aws_subnet.public.*.id[0]

  tags = {
    Name                           = "nat"
  }
}

# To ensure proper ordering, it is recommended to add an explicit dependency
# on the Internet Gateway for the VPC.