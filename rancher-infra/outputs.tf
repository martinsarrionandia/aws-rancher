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

output "letsencrypt-email" {
  value = var.letsencrypt-email
}

output "rancher-secret-arn" {
  value = var.rancher-secret-arn
}

output "s3-prefix-list-id" {
  value = aws_vpc_endpoint.s3.prefix_list_id
}

output "s3-whitelist" {
  value = local.ip_range
}
