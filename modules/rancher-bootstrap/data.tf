data "rancher2_cluster" "this" {
  count = local.is-bootstrapped ? 0 : 1
  name = "local"
  depends_on = [
    rancher2_bootstrap.this
  ]
}