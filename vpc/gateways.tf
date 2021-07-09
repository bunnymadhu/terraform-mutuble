resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}
## igw--internet gateway---------igw is the public subnets and netway is the private subnets...
## rt-route-table