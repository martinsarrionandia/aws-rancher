variable "env-name" {
  description = "Name of the environment"
  type        = string
}

variable "domain-name" {
  description = "DNS Domain name for IAM policy creation"
  type        = string
}

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

variable "subnet-cidr" {
  type    = string
  default = "10.0.1.0/24"
}