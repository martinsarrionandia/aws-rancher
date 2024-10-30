data "terraform_remote_state" "rancher-infra" {
  backend = "s3"

  config = {
    bucket = "sarrionandia.co.uk"
    key    = "terraform-state/aws-rancher/rancher-whitelist/terraform.tfstate"
    region = "eu-west-1"
  }
}