locals {
  fqdn    = "${var.host-name}.${var.domain-name}"
  api_url = "https://${var.host-name}.${var.domain-name}"
}