variable "env-name" {
  description = "Name of the environment"
  type        = string
}

variable "availability-zone" {
  description = "As this is a single node deployment it can only go in one AZ. Set it here"
  type        = string
}

variable "subnet-id" {
  description = "Subnet to deploy the rancher instance"
  type        = string
}

variable "security-groups" {
  description = "List of security groups for the rancher instance"
  type        = list(string)
}

variable "instance-key-name" {
  description = "This sets the SSH Key used for the instance"
  type        = string
}

variable "instance-type" {
  description = "The type of instance to use"
  type        = string
}

variable "instance-profile" {
  description = "The IAM instance profile ARN"
  type        = string
}

variable "volume-size" {
  description = "The size of the instance volume"
  type        = string
  default     = "64"
}

variable "domain-name" {
  description = "This sets the route53 region where records are created"
  type        = string
}

variable "hostname" {
  description = "Hostname of the rancher server"
  type        = string
}

variable "letsencrypt-email" {
  description = "Email address for letsencrpyt certificates"
  type        = string
}

variable "cluster-issuer" {
  type    = string
  default = "letsencrypt-production"
}

variable "rancher-secret-arn" {
  type = string
}