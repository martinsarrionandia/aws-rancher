data "aws_secretsmanager_secret" "rancher_secret" {
  arn = "arn:aws:secretsmanager:eu-west-2:281287281094:secret:host/rancher/users-HrdSJ7"
}

data "aws_secretsmanager_secret_version" "rancher_secret_current" {
  secret_id = data.aws_secretsmanager_secret.rancher_secret.id
}
