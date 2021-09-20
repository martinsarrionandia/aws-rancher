data "aws_secretsmanager_secret" "rancher_admin" {
  arn = "arn:aws:secretsmanager:eu-west-2:281287281094:secret:host/rancher/users-HrdSJ7"
}

data "aws_secretsmanager_secret_version" "rancher_admin_current" {
  secret_id = data.aws_secretsmanager_secret.rancher_admin.id
}

resource "aws_secretsmanager_secret" "rancher_token" {
  name                    = "host/rancher/token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rancher_token_current" {
  secret_id     = aws_secretsmanager_secret.rancher_token.id
  secret_string = jsonencode(local.rancher_token_string)
}

locals {
  rancher_token_string = {
    token = rancher2_bootstrap.admin.token
  }
}