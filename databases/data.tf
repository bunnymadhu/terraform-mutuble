data "aws_ami" "centos7" {
  most_recent      = true
  name_regex       = "^Centos-7-DevOps-Practice"
  owners           = ["973714476881"]
}

## terraform_ami_EC2_Data Sources_aws-ami

output "ami" {
  value = data.aws_ami.centos7
}