resource "aws_elasticache_cluster" "example" {
  cluster_id                                = "redis-${var.ENV}"
  engine                                    = "redis"
  node_type                               = "cache.t3.micro"
  num_cache_nodes                   = 1
  parameter_group_name            = "default.redis5.0"
  engine_version                         = "5.0.6"
  port                                         = 6379
}

## it is registry.terraform.io_aws_elasticache_cluster_redis

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