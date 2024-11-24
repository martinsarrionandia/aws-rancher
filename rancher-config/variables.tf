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
  type    = string
  default = "true"
}

variable "traefik-external-access-policy" {
  description = "Set to Local for middleware IP Whitelist to work"
  type        = string
  default     = "Local"
}