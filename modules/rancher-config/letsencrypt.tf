resource "kubernetes_manifest" "certmanager-letsencrypt" {
  manifest = yamldecode(templatefile("${path.module}/templates/letsencrypt.yaml",
    {
      letsencrypt_email = var.letsencrypt_email
      cluster_issuer    = var.cluster_issuer
  }))
}