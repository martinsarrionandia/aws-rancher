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

variable "ip-whitelist-additional" {
  description = "Additional IP ranges for IP whitelist"
  type        = list(any)
  default     = ["10.1.0.1/32"]
}