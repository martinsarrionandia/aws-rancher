variable "region" {
  description = "Region to deploy rancher infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "availability-zone" {
  description = "As this is a single node deployment it can only go in one AZ. Set it here"
  type        = string
  default     = "eu-west-2a"
}

variable "rancher-subnet-cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "instance-key-name" {
  description = "This sets the SSH Key used for the instance"
  type        = string
  default     = "sarrionandia-eu-w2"
}

variable "domain-name" {
  description = "This sets the route53 region where records are created"
  type        = string
  default     = "sarrionandia.co.uk"
}

variable "host-name" {
  description = "Hostname of the rancher server"
  type        = string
  default     = "rancher"
}

variable "letsencrypt-email" {
  description = "Email address for letsencrpyt certificates"
  type        = string
  default     = "martin@sarrionandia.co.uk"
}

variable "cluster-issuer" {
  type    = string
  default = "letsencrypt-production"
}

variable "rancher-secret-arn" {
  type    = string
  default = "arn:aws:secretsmanager:eu-west-2:281287281094:secret:rancher-QeIi1B"
}