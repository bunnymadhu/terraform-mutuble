variable "ENV" {}

output "outputs" {
  value = data.terraform_remote_state.vpc.outputs
}