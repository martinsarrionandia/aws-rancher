data "aws_secretsmanager_secret" "rancher_admin" {
  arn = "arn:aws:secretsmanager:eu-west-2:281287281094:secret:host/rancher/users-HrdSJ7"
}

data "aws_secretsmanager_secret_version" "rancher_admin_current" {
  secret_id = data.aws_secretsmanager_secret.rancher_admin.id
}