module "rancher-infra" {
  source                  = "./modules/rancher-infra"
  env_name                = local.work-env
  region                  = local.region
  availability_zone       = local.availability_zone
  subnet_cidr             = var.subnet_cidr
  ip_allowlist_additional = var.ip_allowlist_additional
  domain_name             = var.domain_name
}

module "rancher-instance" {
  source             = "./modules/rancher-instance"
  env_name           = local.work-env
  availability_zone  = local.availability_zone
  instance_key_name  = var.instance_key_name
  instance_type      = var.instance_type
  hostname           = var.hostname
  domain_name        = module.rancher-infra.domain_name
  instance_profile   = module.rancher-infra.instance-profile
  rancher_secret_arn = var.rancher_secret_arn
  letsencrypt_email  = var.letsencrypt_email
  subnet-id          = module.rancher-infra.subnet-id
  security_groups    = module.rancher-infra.security_groups
}

module "rancher-allowlist" {
  source                  = "./modules/rancher-allowlist"
  env_name                = local.work-env
  instance_ids            = module.rancher-instance.instance_ids
  ip_allowlist_additional = var.ip_allowlist_additional
}

module "rancher-bootstrap" {
  source             = "./modules/rancher-bootstrap"
  api_url            = module.rancher-instance.api_url
  fqdn               = module.rancher-instance.fqdn
  rancher_secret_arn = var.rancher_secret_arn
}

module "rancher-config" {
  source                  = "./modules/rancher-config"
  region                  = module.rancher-infra.region
  rancher_secret_arn      = var.rancher_secret_arn
  letsencrypt_email       = var.letsencrypt_email
  ip_allowlist_additional = var.ip_allowlist_additional
  fqdn                    = module.rancher-instance.fqdn
  rancher_role_arn        = module.rancher-infra.rancher_role_arn
  public_ip               = module.rancher-instance.public_ip
  domain_name             = module.rancher-infra.domain_name
}
