# Create a new rancher2_bootstrap using bootstrap provider config
resource "rancher2_bootstrap" "admin" {
  provider         = rancher2.bootstrap
  current_password = var.bootstrap_password
  password         = jsondecode(data.aws_secretsmanager_secret_version.rancher_admin_current.secret_string)["admin"]
  telemetry        = true
  depends_on = [aws_eip.rancher]
}