resource "kubernetes_manifest" "certmanager_letsencrypt" {
  manifest = yamldecode(templatefile("${path.module}/templates/letsencrypt.yaml",
    {
      letsencrypt_email = var.letsencrypt_email
      cluster_issuer    = var.cluster_issuer
  }))
}