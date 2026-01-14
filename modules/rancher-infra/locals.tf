
locals {
  region        = "eu-west-1"
  service       = "S3"
  aws_ip_ranges = jsondecode(data.http.aws_ip_ranges.response_body)["prefixes"]

  ip_range = [for i in [local.aws_ip_ranges] : [for j in i : j.ip_prefix if j.region == local.region && j.service == local.service]][0]

  ip-allowlist = setunion(
    var.ip_allowlist_additional,
    ["${chomp(data.http.my_current_ip.response_body)}/32"]
  )
}