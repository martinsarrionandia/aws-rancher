# Create a new rancher2_bootstrap using bootstrap provider config
resource "rancher2_bootstrap" "this" {
  token_ttl        = 86400
  token_update     = true
  provider         = rancher2.bootstrap
  initial_password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["bootstrap"]
  password         = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["admin"]
  telemetry        = true
  lifecycle {
    ignore_changes = all
  }
}