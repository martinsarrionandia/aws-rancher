data "local_file" "kubectl_config" {
  filename = module.rancher-bootstrap.kubectl-file

}

data "external" "env" {
  program = ["${path.module}/env.sh"]
}