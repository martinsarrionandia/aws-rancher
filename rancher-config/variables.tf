variable "letsencrypt-email" {
  type    = string
  default = "martin@sarrionandia.co.uk"
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
  type    = string
  default = "Local"
}

variable "ip-whitelist-additional" {
  type    = list(any)
  default = ["10.1.0.1/32"]
}