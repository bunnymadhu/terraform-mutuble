resource "aws_db_instance" "default" {
  identifier                            = "mysql-${var.ENV}"
  allocated_storage               = 10
  engine                               = "mysql"
  engine_version                   = "5.7"
  instance_class                    = "db.t3.micro"
  name                                  = "defaultlaunched"
  username                           = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["RDS_MYSQL_user"]
  password                            = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["RDS_MYSQL_passowrd"]
  parameter_group_name       = "default.mysql5.7"
  skip_final_snapshot             = true
  vpc_security_group_ids       = [aws_security_group.allow_rds_mysql.id]
  db_subnet_group_name       = aws_db_subnet_group.subnet-group.name
  tags                                    = {
    Name                                = "mysql-${var.ENV}"
    Environment                      = var.ENV

  }
}

## it is in terraform_rds_aws_db_instance
## we may go with instance in this  practice but in companies might go with clusters...same clusters are in  given path...
## identifier is nothing but the Name that should be the displaying on the UI...


## it is in terraform_rds_aws_db_subnet group

resource "aws_db_subnet_group" "subnet-group" {
  name                                 = "mysql-db-group-${var.ENV}"
  subnet_ids                         = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS

  tags = {
    Name                               = "mysql-db-group-${var.ENV}"
    Environment                     = var.ENV
  }
}

resource "aws_security_group" "allow_rds_mysql" {
  name                                = "allow_rds_mysql"
  description                        = "AllowRdsMySQL"
  vpc_id                              = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description                     = "MYSQL"
    from_port                       = 3306
    to_port                           = 3306
    protocol                         = "tcp"
    cidr_blocks                    = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  ## for MONGODB we need to allow ONLY internal to this VPC not needed externalother vpc's...(VPC_CIDR)....
  ## tcp----Transmission Control Protocol----TCP stands for Transmission Control Protocol a communications standard that enables application programs and computing devices to                                                                       exchange messages over a network. It is designed to send packets across the internet and ensure the successful delivery of data and                                                                        messages over networks..

  egress {
    from_port                       = 0
    to_port                           = 0
    protocol                         = "-1"
    cidr_blocks                    = ["0.0.0.0/0"]
    ipv6_cidr_blocks            = ["::/0"]
  }

  tags                               = {
    Name                           = "AllowRdsMySQL"
    Environment                  = var.ENV
  }
}