data "local_file" "kube_config" {
  filename = local.kube-config-file
}

data "external" "env" {
  program = ["${path.module}/env.sh"]
}