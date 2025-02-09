resource "local_file" "this_kube_config" {
  content         = local.kubectl-content
  filename        = local.kubectl-file
  file_permission = "0600"
  lifecycle {
    ignore_changes = all
  }
  depends_on = [data.rancher2_cluster.this]
}

resource "time_sleep" "cluster_ready_timer" {
  create_duration = "120s"
  depends_on = [
    local_file.this_kube_config
  ]
}