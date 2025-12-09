locals {
  kubectl-file    = pathexpand("~/.kube/${var.fqdn}")
  is-bootstrapped = fileexists(local.kubectl-file) ? true : false
}