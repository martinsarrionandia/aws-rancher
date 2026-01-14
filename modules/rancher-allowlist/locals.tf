locals {

  ip-allowlist = setunion(
    var.ip_allowlist_additional,
    ["${chomp(data.http.my_current_ip.response_body)}/32"]
  )
}