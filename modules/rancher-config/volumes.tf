resource "kubernetes_persistent_volume_claim_v1" "traefik_plugins" {
  wait_until_bound = false
  metadata {
    name      = "traefik-plugins-claim"
    namespace = "traefik"
    annotations = {
      volumeType = "local"
    }
  }

  spec {
    storage_class_name = "local-path"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}