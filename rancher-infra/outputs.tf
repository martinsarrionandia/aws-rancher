output "api-url" {
  value = local.api_url
}

output "fqdn" {
  value = local.fqdn
}

output "public-ip" {
  value = aws_eip.rancher.public_ip
}

output "rancher-role-arn" {
  value = aws_iam_role.rancher.arn
}

output "region" {
  value = var.region
}