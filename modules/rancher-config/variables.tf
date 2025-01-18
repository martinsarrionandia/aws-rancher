variable "region" {
  type = string
}

variable "cluster-issuer" {
  type    = string
  default = "letsencrypt"
}

variable "amazon-ebs-class" {
  type    = string
  default = "amazon-ebs"
}

variable "external-dns-name" {
  type    = string
  default = "external-dns"
}

variable "crowdsec-name" {
  type    = string
  default = "crowdsec"
}

variable "crowdsec-namespace" {
  type    = string
  default = "crowdsec"
}

variable "bouncer" {
  type    = string
  default = "bouncer"
}

variable "traefik-namespace" {
  type    = string
  default = "traefik"
}

variable "crowdsec-privileged" {
  type    = bool
  default = "true"
}

variable "traefik-log-level" {
  type    = string
  default = "INFO"
  #default = "DEBUG"
}

variable "traefik-access-log" {
  type    = bool
  default = "true"
}

variable "traefik-external-access-policy" {
  description = "Set to Local for middleware IP Whitelist to work"
  type        = string
  default     = "Local"
}

variable "ip-allowlist-additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
  default     = []
}

variable "rancher-secret-arn" {
  type = string
}

variable "fqdn" {
  type = string
}

variable "letsencrypt-email" {
  type = string
}

variable "rancher-role-arn" {
  type = string
}
