data "aws_secretsmanager_secret" "rancher_admin" {
  arn = data.terraform_remote_state.rancher-infra.outputs.rancher-secret-arn
}

data "aws_secretsmanager_secret_version" "rancher_admin_current" {
  secret_id = data.aws_secretsmanager_secret.rancher_admin.id
}