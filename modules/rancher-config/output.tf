output "cluster-issuer" {
  value = var.cluster-issuer
}

output "amazon-ebs-class" {
  value = var.amazon-ebs-class
}

output "crowdsec-bouncer-middleware" {
  value = "${var.traefik-namespace}-${var.bouncer}@kubernetescrd"
}