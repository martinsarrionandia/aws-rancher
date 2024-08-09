resource "local_file" "kube_config" {
  content         = data.rancher2_cluster.local.kube_config
  filename        = pathexpand("~/.kube/config")
  file_permission = "0600"
}
