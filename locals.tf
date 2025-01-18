locals {
  region            = data.external.env.result["region"]
  az                = data.external.env.result["az"]
  availability-zone = "${local.region}${local.az}"
  work-env          = data.external.env.result["work_env"]
  kube-config-file  = pathexpand("~/.kube/${module.rancher-instance.fqdn}")
}