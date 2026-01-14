variable "cluster_issuer" {
  type    = string
  default = "letsencrypt"
}

variable "amazon_ebs_class" {
  type    = string
  default = "amazon-ebs"
}

variable "external_dns_name" {
  type    = string
  default = "external-dns"
}

variable "crowdsec-name" {
  type    = string
  default = "crowdsec"
}

variable "crowdsec_namespace" {
  type    = string
  default = "crowdsec"
}

variable "bouncer" {
  type    = string
  default = "bouncer"
}

variable "traefik_namespace" {
  type    = string
  default = "traefik"
}

variable "crowdsec_privileged" {
  type    = bool
  default = "true"
}

variable "traefik_log_level" {
  type    = string
  default = "INFO"
  #default = "DEBUG"
}

variable "traefik_access_log" {
  type    = bool
  default = "true"
}

variable "traefik-external-access-policy" {
  description = "Set to Local for middleware IP Whitelist to work"
  type        = string
  default     = "Local"
}

variable "ip_allowlist_additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
  default     = []
}

variable "rancher_secret_arn" {
  type = string
}

variable "fqdn" {
  type = string
}

variable "letsencrypt_email" {
  type = string
}

variable "rancher_role_arn" {
  type = string
}

variable "domain_name" {
  description = "DNS Domain name for IAM policy creation"
  type        = string
}

variable "public_ip" {
  description = "Public IP address of the instance"
  type        = string
}

variable "region" {
  description = "Region to deploy rancher infrastructure"
  type        = string
  default     = "eu-west-2"
}