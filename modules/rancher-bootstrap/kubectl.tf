resource "local_file" "this_kube_config" {
  content         = data.rancher2_cluster.this.kube_config
  filename        = pathexpand("~/.kube/config")
  file_permission = "0600"
  lifecycle {
    ignore_changes = all
  }
}

resource "time_sleep" "cluster_ready_timer" {
  create_duration = "5s"
  depends_on = [
    local_file.this_kube_config
  ]
}