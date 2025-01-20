locals {

  ip-allowlist = setunion(
    var.ip-allowlist-additional,
    ["${chomp(data.http.my_current_ip.response_body)}/32"]
  )
}