output "api_url" {
  value = local.api_url
}

output "api_secret_arn" {
  value = aws_secretsmanager_secret.rancher_token.arn
}

#output "kube_config" {
#  value = data.rancher2_cluster.local.kube_config
#}
