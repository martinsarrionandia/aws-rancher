resource "local_file" "kubectl" {
  content  = fileexists(pathexpand("~/.kube/config_exists")) ? file(pathexpand("~/.kube/config")) :data.rancher2_cluster.local.kube_config
  filename = pathexpand("~/.kube/config")
}

resource "local_file" "kubectl_exists" {
  content  = "created"
  filename = pathexpand("~/.kube/config_exists")
  depends_on = [
    local_file.kubectl
  ]
}