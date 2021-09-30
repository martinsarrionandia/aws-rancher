# Nasty hack to stop kube config file being downloaded each time terraform is run. This is because the admin token changes every time you download it.
resource "local_file" "kubectl" {
  content  = fileexists(pathexpand("~/.kube/config_exists")) ? file(pathexpand("~/.kube/config")) :data.rancher2_cluster.local.kube_config
  filename = pathexpand("~/.kube/config")
  file_permission = "0600"
}

resource "local_file" "kubectl_exists" {
  content  = "created"
  filename = pathexpand("~/.kube/config_exists")
  file_permission = "0600"
  depends_on = [
    local_file.kubectl
  ]
}