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