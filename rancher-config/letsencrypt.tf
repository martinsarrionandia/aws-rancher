resource "kubernetes_manifest" "certmanager-letsencrypt" {
  manifest = yamldecode(templatefile("${path.module}/templates/letsencrypt.yaml",
    {
      letsencrypt-email = data.terraform_remote_state.rancher-infra.outputs.letsencrypt-email
      cluster-issuer    = var.cluster-issuer
  }))
}

locals {

  letsencrypt-cluster-issuer = <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: "${var.cluster-issuer}"
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: "${data.terraform_remote_state.rancher-infra.outputs.letsencrypt-email}
    privateKeySecretRef:
      name: "${var.cluster-issuer}"
    solvers:
    - http01:
        ingress:
          class: traefik
EOF
}