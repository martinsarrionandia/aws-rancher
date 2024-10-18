terraform {
  backend "s3" {
    bucket  = var.domain_name
    key     = "terraform-state/aws-rancher/rancher-infra/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}