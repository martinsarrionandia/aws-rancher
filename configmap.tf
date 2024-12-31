resource "kubernetes_config_map" "this" {
  metadata {
    name      = "aws-rancher-config"
    namespace = "default"
  }

  data = {
    amazon-ebs-class            = module.rancher-config.amazon-ebs-class
    dcluster-issuer             = module.rancher-config.cluster-issuer
    crowdsec-bouncer-middleware = module.rancher-config.crowdsec-bouncer-middleware
    public-ip                   = module.rancher-instance.public-ip
    rancher-rol-arn             = module.rancher-infra.rancher-role-arn
    region                      = module.rancher-infra.region
    rancher-secret-arn          = var.rancher-secret-arn
    domain-name                 = module.rancher-infra.domain-name
  }
}