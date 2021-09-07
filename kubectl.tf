resource "local_file" "kubectl" {
    content     = data.rancher2_cluster.local.kube_config
    filename    = pathexpand("~/.kube/config")
}