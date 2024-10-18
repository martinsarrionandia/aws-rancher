data "aws_secretsmanager_secret" "rancher" {
  arn = var.rancher-secret-arn
}

data "aws_secretsmanager_secret_version" "rancher-current" {
  secret_id = data.aws_secretsmanager_secret.rancher.id
}