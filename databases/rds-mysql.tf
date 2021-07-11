//resource "aws_db_instance" "default" {
//  allocated_storage    = 10
//  engine               = "mysql"
//  engine_version       = "5.7"
//  instance_class       = "db.t3.micro"
//  name                 = "default-launched"
//  username             = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["RDS_MYSQL_USER"]
//  password             = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["RDS_MYSQL_PASS"]
//  parameter_group_name = "default.mysql5.7"
//  skip_final_snapshot  = true
//}

## it is in terraform_rds_aws_db_instance
## we may go with instance in this  practice but in companies might go with clusters...same clusters are in  given path...