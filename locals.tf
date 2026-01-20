locals {
  region              = data.external.env.result["region"]
  az                  = data.external.env.result["az"]
  availability_zone   = "${local.region}${local.az}"
  work_env            = data.external.env.result["work_env"]
  kubectl_config_file = pathexpand("~/.kube/${module.rancher-bootstrap.kubectl_file}")
}