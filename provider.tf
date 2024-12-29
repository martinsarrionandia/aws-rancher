provider "aws" {
  region = var.region
}

# Helm Provider
provider "helm" {
  kubernetes {
    config_path = data.local_file.kube_config.filename
  }
}

# Kubernetes Provider
provider "kubernetes" {
  config_path = data.local_file.kube_config.filename
}