data "rancher2_cluster" "this" {
  name = "local"
  depends_on = [
    rancher2_bootstrap.this
  ]
}

resource "time_sleep" "cluster_ready_timer" {
  create_duration = "60s"

  depends_on = [
    local_file.this_kube_config
  ]
}