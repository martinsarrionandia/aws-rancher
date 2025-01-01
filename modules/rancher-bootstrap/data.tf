data "rancher2_cluster" "this" {
  name = "local"
  depends_on = [
    rancher2_bootstrap.this
  ]
}