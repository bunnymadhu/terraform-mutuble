provider "aws" {
  region = "us-east-1"
}

//terraform {
//  backend "s3" {}

terraform {
  backend "s3" {}
}