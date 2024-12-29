resource "local_file" "this_kube_config" {
  content         = data.rancher2_cluster.this.kube_config
  filename        = pathexpand("~/.kube/config")
  file_permission = "0600"
}