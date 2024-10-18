resource "kubernetes_manifest" "certmanager-letsencrypt" {
  manifest = yamldecode(templatefile("${path.module}/templates/letsencrypt.yaml",
    {
      letsencrypt-email = data.terraform_remote_state.rancher-infra.outputs.letsencrpyt-email
      cluster-issuer    = var.cluster-issuer
  }))
}