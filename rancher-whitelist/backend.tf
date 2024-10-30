terraform {
  backend "s3" {
    bucket  = "sarrionandia.co.uk"
    key     = "terraform-state/aws-rancher/rancher-config/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}