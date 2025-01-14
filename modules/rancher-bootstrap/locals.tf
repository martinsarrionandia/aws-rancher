locals {
  kubectl-file    = pathexpand("~/.kube/${var.fqdn}")
  is-bootstrapped = fileexists(local.kubectl-file) ? true : false
  kubectl-content = try(data.rancher2_cluster.this[0].kube_config, "already-bootstrapped")
}