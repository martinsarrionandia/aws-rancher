resource "kubernetes_manifest" "certmanager-letsencrypt" {
  manifest = yamldecode(templatefile("${path.module}/templates/letsencrypt.yaml",
    {
      letsencrypt-email = var.letsencrypt-email,
      cluster-issuer    = var.cluster-issuer
  }))
}