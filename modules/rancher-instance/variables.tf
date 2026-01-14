variable "env_name" {
  description = "Name of the environment"
  type        = string
}

variable "availability_zone" {
  description = "As this is a single node deployment it can only go in one AZ. Set it here"
  type        = string
}

variable "subnet-id" {
  description = "Subnet to deploy the rancher instance"
  type        = string
}

variable "security_groups" {
  description = "Map of security groups for the rancher instance"
  type        = map(string)
}

variable "instance_key_name" {
  description = "This sets the SSH Key used for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
}

variable "instance_profile" {
  description = "The IAM instance profile ARN"
  type        = string
}

variable "volume-size" {
  description = "The size of the instance volume"
  type        = string
  default     = "64"
}

variable "domain_name" {
  description = "This sets the route53 region where records are created"
  type        = string
}

variable "hostname" {
  description = "Hostname of the rancher server"
  type        = string
}

variable "letsencrypt_email" {
  description = "Email address for letsencrpyt certificates"
  type        = string
}

variable "cluster_issuer" {
  type    = string
  default = "letsencrypt-production"
}

variable "rancher_secret_arn" {
  type = string
}