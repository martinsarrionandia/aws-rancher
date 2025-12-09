# Create a new rancher2_bootstrap using bootstrap provider config
resource "rancher2_bootstrap" "this" {
  token_ttl        = 120
  token_update     = false
  provider         = rancher2.bootstrap
  initial_password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["bootstrap"]
  password         = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["admin"]
  lifecycle {
    ignore_changes = all
  }
}