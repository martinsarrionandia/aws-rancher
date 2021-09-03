terraform {
  backend "s3" {
    bucket = "sarrionandia.co.uk"
    key    = "terraform-state/aws-rancher"
    region = "eu-west-1"
  }
}