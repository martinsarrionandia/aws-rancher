
locals {
  fqdn    = "${var.hostname}.${var.domain_name}"
  api_url = "https://${local.fqdn}"
}