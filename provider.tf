provider "aws" {
  region = "eu-west-2"
}

# Provider bootstrap config with alias
provider "rancher2" {
  alias = "bootstrap"

  api_url   = local.api_url
  bootstrap = true
  insecure  = true
  timeout   = "300s"
}

# Provider rancher2 post bootstrap
provider "rancher2" {

  api_url   = local.api_url
  token_key = rancher2_bootstrap.admin.token
  insecure  = true
}

locals {
  api_url = "https://${aws_instance.rancher.public_ip}"
}