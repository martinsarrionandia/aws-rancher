module "prod-infra" {
  source      = "./modules/rancher-infra"
  env-name    = "Container"
  domain-name = "sarrionandia.co.uk"
}

module "prod-instance" {
  source             = "./modules/rancher-instance"
  env-name           = "Container"
  instance-key-name  = "sarrionandia-eu-w2"
  host-name          = "rancher"
  domain-name        = module.prod-infra.domain-name
  instance-profile   = module.prod-infra.instance-profile
  rancher-secret-arn = var.rancher-secret-arn
  letsencrypt-email  = var.letsencrypt-email
  subnet-id          = module.prod-infra.subnet-id
  security-groups    = module.prod-infra.security-groups
}

module "prod-bootstrap" {
  source             = "./modules/rancher-bootstrap"
  api-url            = module.prod-instance.api-url
  rancher-secret-arn = var.rancher-secret-arn
}

module "prod-config" {
  source                  = "./modules/rancher-config"
  region                  = module.prod-infra.region
  rancher-secret-arn      = var.rancher-secret-arn
  letsencrypt-email       = var.letsencrypt-email
  ip-allowlist-additional = var.ip-allowlist-additional
  fqdn                    = module.prod-instance.fqdn
  rancher-role-arn        = module.prod-infra.rancher-role-arn
}