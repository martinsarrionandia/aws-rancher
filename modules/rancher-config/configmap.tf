resource "kubernetes_config_map_v1" "this" {
  metadata {
    name      = "aws-rancher-config"
    namespace = "default"
  }

  data = {
    amazon-ebs-class            = var.amazon_ebs_class
    cluster-issuer              = var.cluster_issuer
    crowdsec-bouncer-middleware = local.crowdsec_bouncer_middleware
    public-ip                   = var.public_ip
    region                      = var.region
    domain-name                 = var.domain_name
    http-proxy-namespace        = kubernetes_namespace_v1.proxy.metadata[0].name
    http-proxy-app              = var.squid_name
    http-proxy-address          = "${var.squid_name}.${kubernetes_namespace_v1.proxy.metadata[0].name}:${var.squid_port}"
    http-proxy = jsonencode(
      {
        namespace = kubernetes_namespace_v1.proxy.metadata[0].name
        app       = var.squid_name
        address   = "${var.squid_name}.${kubernetes_namespace_v1.proxy.metadata[0].name}:${var.squid_port}"
      }
    )
    crowdsec-bouncer-middleware-map = jsonencode(
      {
        name      = var.bouncer
        namespace = var.traefik_namespace
      }
    )
  }
}