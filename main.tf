module "rancher-infra" {
  source      = "./modules/rancher-infra"
  env-name    = "Container"
  domain-name = "sarrionandia.co.uk"
}

module "rancher-instance" {
  source             = "./modules/rancher-instance"
  env-name           = "Container"
  instance-key-name  = "sarrionandia-eu-w2"
  host-name          = "rancher"
  domain-name        = module.rancher-infra.domain-name
  instance-profile   = module.rancher-infra.instance-profile
  rancher-secret-arn = var.rancher-secret-arn
  letsencrypt-email  = var.letsencrypt-email
  subnet-id          = module.rancher-infra.subnet-id
  security-groups    = module.rancher-infra.security-groups
}

module "rancher-bootstrap" {
  source             = "./modules/rancher-bootstrap"
  api-url            = module.rancher-instance.api-url
  rancher-secret-arn = var.rancher-secret-arn
}

module "rancher-config" {
  source                  = "./modules/rancher-config"
  region                  = module.rancher-infra.region
  rancher-secret-arn      = var.rancher-secret-arn
  letsencrypt-email       = var.letsencrypt-email
  ip-allowlist-additional = var.ip-allowlist-additional
  fqdn                    = module.rancher-instance.fqdn
  rancher-role-arn        = module.rancher-infra.rancher-role-arn
}