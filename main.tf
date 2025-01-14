module "rancher-infra" {
  source            = "./modules/rancher-infra"
  env-name          = var.env-name
  region            = var.region
  availability-zone = var.availability-zone
  subnet-cidr       = var.subnet-cidr
  domain-name       = var.domain-name
}

module "rancher-instance" {
  source             = "./modules/rancher-instance"
  env-name           = var.env-name
  availability-zone  = var.availability-zone
  instance-key-name  = var.instance-key-name
  instance-type      = var.instance-type
  hostname           = var.hostname
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
  fqdn               = module.rancher-instance.fqdn
  rancher-secret-arn = var.rancher-secret-arn
}

module "rancher-config" {
  depends_on              = [module.rancher-bootstrap]
  source                  = "./modules/rancher-config"
  region                  = module.rancher-infra.region
  rancher-secret-arn      = var.rancher-secret-arn
  letsencrypt-email       = var.letsencrypt-email
  ip-allowlist-additional = var.ip-allowlist-additional
  fqdn                    = module.rancher-instance.fqdn
  rancher-role-arn        = module.rancher-infra.rancher-role-arn
}