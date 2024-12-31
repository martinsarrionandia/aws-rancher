output "api-url" {
  value = local.api_url
}

output "fqdn" {
  value = local.fqdn
}

output "public-ip" {
  value = aws_eip.this.address
}