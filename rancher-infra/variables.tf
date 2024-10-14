variable "region"{
  type = string
  default = "eu-west-2"
}

variable "availability-zone" {
  type    = string
  default = "eu-west-2a"
}

variable "rancher-subnet-cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "instance-key-name" {
  type    = string
  default = "sarrionandia-eu-w2"
}

variable "domain-name" {
  type    = string
  default = "sarrionandia.co.uk"
}

variable "host-name" {
  type    = string
  default = "rancher"
}

variable "letsencrypt-email" {
  type    = string
  default = "martin@sarrionandia.co.uk"
}

variable "cluster-issuer" {
  type    = string
  default = "letsencrypt-production"
}
