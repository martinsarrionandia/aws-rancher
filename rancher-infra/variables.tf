variable "availability_zone" {
  type    = string
  default = "eu-west-2a"
}

variable "rancher_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "bootstrap_password" {
  type    = string
  default = "changemerealquickamigo"
}

variable "instance_key_name" {
  type    = string
  default = "sarrionandia-eu-w2"
}

variable "domain_name" {
  type    = string
  default = "sarrionandia.co.uk"
}

variable "host_name" {
  type    = string
  default = "rancher"
}

variable "rancher_admin_http" {
  type    = string
  default = "8080"
}

variable "rancher_admin_https" {
  type    = string
  default = "443"
}

variable "traefik_node_port_http" {
  type    = string
  default = "30080"
}

variable "traefik_node_port_https" {
  type    = string
  default = "30443"
}