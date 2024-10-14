data "aws_secretsmanager_secret" "rancher" {
  arn = "arn:aws:secretsmanager:eu-west-2:281287281094:secret:rancher-QeIi1B"
}

data "aws_secretsmanager_secret_version" "rancher-current" {
  secret_id = data.aws_secretsmanager_secret.rancher.id
}