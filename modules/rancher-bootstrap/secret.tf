data "aws_secretsmanager_secret" "this" {
  arn = var.rancher-secret-arn
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.this.id
}