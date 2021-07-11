data "aws_ami" "centos7" {
  most_recent                            = true
  name_regex                            = "^Centos-7-DevOps-Practice"
  owners                                   = ["973714476881"]
}

## terraform_ami_EC2_Data Sources_aws-ami

//output "ami" {
//  value = data.aws_ami.centos7
//}


## from terraform state file_data source_....in chrome
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket                             = "terraform--batch56"
    key                                 = "mutuble/vpc/${var.ENV}/terraform.tfstate"
    region                             = "us-east-1"
    }
  }

output "outputs" {
  value                                = data.terraform_remote_state.vpc.outputs
}

## terraform_Data_sources_aws_secretsmanager_secret

data "aws_secretsmanager_secret" "secrets" {
  name                              = "${var.ENV}-env"
}

## here why we give ${var,ENV} because in AWS_secretmanager we can save as name--    dev-env

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id                        = data.aws_secretsmanager_secret.secrets.id
}

output "secrets" {
  sensitive                       = true
  value                            = data.aws_secretsmanager_secret_version.secrets
}


## in AWS  there is secretsmanager which stores only secrets...so we can give dev_ENV as SSH_user name(centos) and SSH_password(Devops321)




