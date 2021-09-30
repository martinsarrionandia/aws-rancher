resource "helm_release" "ambassador" {
  create_namespace = true
  namespace        = "ambassador"
  name             = "ambassador"
  repository       = "https://getambassador.io"
  chart            = "ambassador"
  #version          = "6.7.1100"
  depends_on = [
    data.rancher2_cluster.local,
    local_file.kubectl,
    aws_instance.rancher,
    aws_security_group_rule.racher_admin_https
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
    name = "ambassador-nodeport"
    namespace = helm_release.ambassador.metadata.0.namespace
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = helm_release.ambassador.metadata.0.name
      "app.kubernetes.io/name" = helm_release.ambassador.metadata.0.name
    }
    session_affinity = "ClientIP"

    port {
      name = "http"
      port        = 80
      target_port = 8080
      node_port   = var.ambassador_node_port_http
    }

    port {
      name = "https"
      port        = 443
      target_port = 8443
      node_port   = var.ambassador_node_port_https
    }

    type = "NodePort"
  }
    depends_on = [
      aws_instance.rancher,
      aws_security_group_rule.racher_admin_https
    ]
}