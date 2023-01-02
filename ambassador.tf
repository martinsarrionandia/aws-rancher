resource "helm_release" "ambassador" {
  create_namespace = true
  namespace        = "ambassador"
  name             = "ambassador"
  repository       = "https://getambassador.io"
  chart            = "ambassador"
  version          = "6.7.1100"
  depends_on = [
    time_sleep.cluster_ready_timer,
    local_file.kube_config
  ]

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}

resource "kubernetes_service" "ambassador" {
  metadata {
    name      = "ambassador-nodeport"
    namespace = helm_release.ambassador.metadata.0.namespace
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = helm_release.ambassador.metadata.0.name
      "app.kubernetes.io/name"     = helm_release.ambassador.metadata.0.name
    }
    session_affinity = "ClientIP"

    port {
      name        = "http"
      port        = 80
      target_port = 8080
      node_port   = var.ambassador_node_port_http
    }

    port {
      name        = "https"
      port        = 443
      target_port = 8443
      node_port   = var.ambassador_node_port_https
    }

    type = "NodePort"
  }
  depends_on = [
    local_file.kube_config,
  ]
}