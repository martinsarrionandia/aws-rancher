output "public_ip" {
  value = module.rancher-instance.public_ip
}

output "fqdn" {
  value = module.rancher-instance.fqdn
}