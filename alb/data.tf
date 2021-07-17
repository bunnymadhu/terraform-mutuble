## from terraform state file_data source_....in chrome
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket                             = "terraform--batch56"
    key                                 = "mutuble/vpc/${var.ENV}/terraform.tfstate"
    region                             = "us-east-1"
    }
  }




## to decode the data from this secretmanager code with help of in chrome base64 encode terraform



