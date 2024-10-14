# Helm Provider
provider "helm" {
  kubernetes {
    config_path = data.local_file.kube_config.filename
  }
}

# Kubernetes Provider
provider "kubernetes" {
  config_path = data.local_file.kube_config.filename
  #insecure    = true
}