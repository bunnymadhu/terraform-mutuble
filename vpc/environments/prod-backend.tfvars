bucket                             = "terraform--batch56"
key                                 = "mutuble/vpc/prod/terraform.tfstate"
region                             = "us-east-1"
dynamodb_table              = "terraform"

## if u apply in this u should remove rm -rf .terraform in putty then terraform init will not happend properly will overwrite on to the  environments....
## rm -rf .terraform
## terraform init -backend-config=environments/dev.tfvars