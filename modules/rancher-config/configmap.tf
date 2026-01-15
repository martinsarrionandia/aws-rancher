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
  }
}