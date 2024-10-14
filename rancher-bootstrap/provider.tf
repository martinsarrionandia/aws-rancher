# Provider bootstrap config with alias
provider "rancher2" {
  alias = "bootstrap"

  api_url   = data.terraform_remote_state.rancher-infra.outputs.api-url
  bootstrap = true
  insecure  = false
  timeout   = "300s"
}

# Provider rancher2 post bootstrap
provider "rancher2" {

  api_url   = data.terraform_remote_state.rancher-infra.outputs.api-url
  token_key = rancher2_bootstrap.admin.token
}

# Helm Provider
provider "helm" {
  kubernetes {
    config_path = local_file.kube_config.filename
  }
}

# Kubernetes Provider
provider "kubernetes" {
  config_path = local_file.kube_config.filename
  insecure    = false
}