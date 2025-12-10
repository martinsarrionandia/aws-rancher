provider "aws" {
  region = local.region
  default_tags {
    tags = {
      Environment = local.work-env
      ManagedBy   = "terraform"
      Repo        = "https://github.com/martinsarrionandia/aws-rancher"
    }
  }
}

# Helm Provider
provider "helm" {
  kubernetes = {
    config_path = data.local_file.kubectl_config.filename
  }
}

# Kubernetes Provider
provider "kubernetes" {
  config_path = data.local_file.kubectl_config.filename
}