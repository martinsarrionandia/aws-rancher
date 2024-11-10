
locals {
  fqdn    = "${var.host-name}.${var.domain-name}"
  api_url = "https://${var.host-name}.${var.domain-name}"

  region = "eu-west-1"
  service = "S3"
  aws_ip_ranges = jsondecode(data.http.aws_ip_ranges.response_body)["prefixes"]

  ip_range = [for i in [local.aws_ip_ranges]: [for j in i: j.ip_prefix if j.region == local.region && j.service == local.service ]][0]

}