resource "aws_elasticache_cluster" "example" {
  cluster_id                                = "redis-${var.ENV}"
  engine                                    = "redis"
  node_type                               = "cache.t3.micro"
  num_cache_nodes                   = 1
  parameter_group_name            = "default.redis5.0"
  engine_version                         = "5.0.6"
  port                                         = 6379
  security_group_ids                   = [aws_security_group.allow_rds_mysql.id]
  subnet_group_name                 = aws_elasticache_subnet_group.redis-subnet-group.name
}

## it is registry.terraform.io_aws_elasticache_cluster_redis

resource "aws_elasticache_subnet_group" "redis-subnet-group" {
  name                                  = "redis-db-group-${var.ENV}"
  subnet_ids                            = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS

  tags = {
    Name                                = "redis-db-group-${var.ENV}"
    Environment                         = var.ENV
  }
}

## it is in terraform_vpc_aws_Security group

resource "aws_security_group" "allow_elastic_redis" {
  name                                      = "allow_elastic_redis"
  description                              = "AllowElasticRedis"
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
    description                           = "REDIS"
    from_port                             = 6379
    to_port                                 = 6379
    protocol                               = "tcp"
    cidr_blocks                          = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  ## for MONGODB we need to allow ONLY internal to this VPC not needed externalother vpc's...(VPC_CIDR)....
  ## tcp----Transmission Control Protocol----TCP stands for Transmission Control Protocol a communications standard that enables application programs and computing devices to                                                                        exchange messages over a network. It is designed to send packets across the internet and ensure the successful delivery of data and                                                                        messages over networks..
//
  egress {
    from_port                           = 0
    to_port                               = 0
    protocol                             = "-1"
    cidr_blocks                        = ["0.0.0.0/0"]
    ipv6_cidr_blocks                = ["::/0"]
  }

  tags = {
    Name                               = "AllowElasticRedis"
  }
}
## if  we give this data,,it allows in AWS security groups and  it will shows  inbound rules as allow_mongodb...