output "api_url" {
  value = local.api_url
}

output "fqdn" {
  value = local.fqdn
}

output "public_ip" {
  value = aws_eip.this.public_ip
}

output "instance_ids" {
  value = [aws_instance.this.id]
}