data "rancher2_cluster" "local" {
  name = "local"
  depends_on = [
    rancher2_bootstrap.admin,
  ]
}