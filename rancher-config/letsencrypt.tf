resource "kubernetes_manifest" "certmanager-letsencrypt" {
  manifest = yamldecode(templatefile("${path.module}/templates/letsencrypt.yaml",
    {
      letsencrypt-email = data.terraform_remote_state.rancher-infra.outputs.letsencrypt-email
      cluster-issuer    = var.cluster-issuer
  }))
}