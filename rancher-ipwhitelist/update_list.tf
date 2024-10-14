resource "ssh_resource" "always_run" {
  triggers = {
    always_run = "${timestamp()}"
  }

  host         = "some.private-instance.io"
  user         = var.user
  agent        = true

  commands = [
     "touch /tmp/terraform_triggered"
  ]
}

kubectl patch ing/rancher -n cattle-system -p '{"metadata": {"annotations": {"traefik.ingress.kubernetes.io/router.middlewares": "middleware-rancher-ip-whitelist@kubernetescrd"}}}'
