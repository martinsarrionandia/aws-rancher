locals {
  fqdn    = "${var.host_name}.${var.domain_name}"
  api_url = "https://${var.host_name}.${var.domain_name}:${var.rancher_admin_https}"
}