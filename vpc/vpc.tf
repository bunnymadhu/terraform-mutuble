resource "aws_vpc" "main" {
  cidr_block                         = var.VPC_CIDR
  instance_tenancy              = "default"
  enable_dns_hostnames     = true
  enable_dns_support          = true

  ## cat /etc/nginx/default.d/roboshop.conf
  ## nslookup catalogue-dev.roboshop.internal,,,,,,, we added route53.tf for vpc dns so wait for the dns request and we will go to VPC in aws in that whatever u run the vpc it can create one dev right,select and  in that options both enabled DNS Hostnames,DNS Resolution Support...

  tags = {
    Name                            = var.ENV
  }
}

resource "aws_subnet" "public" {
  count                              = length(var.SUBNET_ZONES)
  vpc_id                            = aws_vpc.main.id
  cidr_block                      = element(var.PUBLIC_SUBNETS_CIDR, count.index)
  availability_zone              =  element(var.SUBNET_ZONES, count.index)

  tags = {
    Name                           = "public-subnet-${count.index + 1}"
  }
}

## only taging while adding the name it going to take first as '0' by avoiding that we will give '+ 1'
resource "aws_subnet" "private" {
  count                              = length(var.SUBNET_ZONES)
  vpc_id                            = aws_vpc.main.id
  cidr_block                       = element(var.PRIVATE_SUBNETS_CIDR, count.index)
  availability_zone              =  element(var.SUBNET_ZONES, count.index)

  tags = {
    Name                           = "private-subnet-${count.index + 1}"
  }
}