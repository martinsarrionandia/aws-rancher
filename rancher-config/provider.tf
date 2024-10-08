# Provider bootstrap config with alias
provider "rancher2" {
  alias = "bootstrap"

  api_url   = data.terraform_remote_state.rancher-infra.outputs.api_url
  bootstrap = true
  insecure  = true
  timeout   = "300s"
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
  #insecure    = true
}