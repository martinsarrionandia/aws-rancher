locals {
  kubectl_file    = pathexpand("~/.kube/${var.fqdn}")
  is_bootstrapped = fileexists(local.kubectl_file) ? true : false
}