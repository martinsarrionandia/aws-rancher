locals {
  external_dns_replicas  = 1
  traefik_replicas       = 1
  crowdsec_lapi_replicas = 1
  ebs_csi_replicas       = 1

  ip-allowlist = setunion(
    var.ip_allowlist_additional,
    ["${chomp(data.http.my_current_ip.response_body)}/32"]
  )
  crowdsec_bouncer_middleware = "${var.traefik_namespace}-${var.bouncer}@kubernetescrd"
}