resource "kubernetes_manifest" "traefik-helm-config" {
  manifest = yamldecode(templatefile("${path.module}/templates/traefik_config.yaml",
    {
      traefik-log-level              = var.traefik-log-level,
      traefik-access-log             = var.traefik-access-log,
      traefik-external-access-policy = var.traefik-external-access-policy
  }))
}