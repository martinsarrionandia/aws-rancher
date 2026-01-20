data "local_file" "kubectl_config" {
  filename = module.rancher-bootstrap.kubectl_file

}

data "external" "env" {
  program = ["${path.module}/env.sh"]
}