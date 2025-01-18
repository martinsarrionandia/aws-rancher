provider "aws" {
  region = local.region
}

# Helm Provider
provider "helm" {
  kubernetes {
    config_path = data.local_file.kubectl_config.filename
  }
}

# Kubernetes Provider
provider "kubernetes" {
  config_path = data.local_file.kubectl_config.filename
}