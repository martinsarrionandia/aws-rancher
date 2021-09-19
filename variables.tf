variable "bootstrap_password" {
  type    = string
  default = "changemerealquickamigo"
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
  default = "4434"
}

variable "ambassador_node_port_http" {
  type    = string
  default = "30080"
}

variable "ambassador_node_port_https" {
  type    = string
  default = "30443"
}