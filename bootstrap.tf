# Create a new rancher2_bootstrap using bootstrap provider config
resource "rancher2_bootstrap" "admin" {
  token_ttl        = 86400
  token_update     = true
  provider         = rancher2.bootstrap
  current_password = jsondecode(data.aws_secretsmanager_secret_version.rancher_admin_current.secret_string)["admin"]
  password         = jsondecode(data.aws_secretsmanager_secret_version.rancher_admin_current.secret_string)["admin"]
  telemetry        = true
  depends_on = [
    aws_instance.rancher,
    aws_eip.rancher_mgmt,
    aws_security_group_rule.racher_admin_https,
    aws_route53_record.rancher,
    aws_internet_gateway.gw,
    aws_route_table_association.rancher,
    aws_route.internet_route
  ]
}