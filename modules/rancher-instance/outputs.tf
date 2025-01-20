output "api-url" {
  value = local.api_url
}

output "fqdn" {
  value = local.fqdn
}

output "public-ip" {
  value = aws_eip.this.public_ip
}

output "instance-ids" {
  value = [aws_instance.this.id]
}