variable "env_name" {
  description = "Name of the environment"
  type        = string
}

variable "domain_name" {
  description = "DNS Domain name for IAM policy creation"
  type        = string
}

variable "region" {
  description = "Region to deploy rancher infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "availability_zone" {
  description = "As this is a single node deployment it can only go in one AZ. Set it here"
  type        = string
}

variable "subnet_cidr" {
  type = string
}

variable "ip_allowlist_additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
  default     = []
}