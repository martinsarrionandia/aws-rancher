locals {
  kube-config-file = pathexpand("~/.kube/${module.rancher-instance.fqdn}")
}