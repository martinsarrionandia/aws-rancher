# Provider bootstrap config with alias
provider "rancher2" {
  alias = "bootstrap"

  api_url   = var.api-url
  bootstrap = true
  insecure  = false
  timeout   = "600s"
}

# Provider rancher2 post bootstrap
provider "rancher2" {

  api_url   = var.api-url
  token_key = rancher2_bootstrap.this.token
}