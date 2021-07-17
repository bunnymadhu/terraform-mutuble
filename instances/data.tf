data "aws_ami" "centos7" {
  most_recent                            = true
  name_regex                            = "^Centos-7-DevOps-Practice"
  owners                                   = ["973714476881"]
}

## from terraform state file_data source_....in chrome
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket                             = "terraform--batch56"
    key                                 = "mutuble/vpc/${var.ENV}/terraform.tfstate"
    region                             = "us-east-1"
  }
}

## terraform_Data_sources_aws_secretsmanager_secret

data "aws_secretsmanager_secret" "secrets" {
  name                              = "${var.ENV}-env"
}

## here why we give ${var,ENV} because in AWS_secretmanager we can save as name--    dev-env

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id                        = data.aws_secretsmanager_secret.secrets.id
}
