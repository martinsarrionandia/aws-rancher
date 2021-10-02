data "rancher2_cluster" "local" {
  name = "local"
  depends_on = [
    rancher2_bootstrap.admin
  ]
}

resource "time_sleep" "cluster_ready_timer" {
  create_duration = "20s"

  depends_on = [
    local_file.kube_config
  ]
}