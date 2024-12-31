output "amazon-ebs-class" {
  value = module.rancher-config.amazon-ebs-class
}

output "cluster-issuer" {
  value = module.rancher-config.cluster-issuer
}

output "crowdsec-bouncer-middleware" {
  value = module.rancher-config.crowdsec-bouncer-middleware
}

output "public-ip" {
  value = module.rancher-instance.public-ip
}

output "fqdn" {
  value = module.rancher-instance.fqdn
}