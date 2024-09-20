terraform {
  backend "s3" {
    bucket  = "sarrionandia.co.uk"
    key     = "terraform-state/aws-rancher/rancher-bootstrap/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}