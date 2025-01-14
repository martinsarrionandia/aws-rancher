
locals {
  fqdn    = "${var.hostname}.${var.domain-name}"
  api_url = "https://${local.fqdn}"
}