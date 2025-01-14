variable "env-name" {
  description = "Name of the environment"
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

variable "domain-name" {
  description = "DNS Domain name for IAM policy creation"
  type        = string
}

variable "hostname" {
  description = "Hostname of the rancher server"
  type        = string
}

variable "ip-allowlist-additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
  default     = ["185.77.56.0/24"]
}

variable "rancher-secret-arn" {
  description = "AWS Secret Manager ARN for rancher passwords and secret data"
  type        = string
}

variable "letsencrypt-email" {
  description = "Let's encrypt email for certificate notification events"
  type        = string
}

variable "instance-type" {
  description = "The type of instance to use"
  type        = string
  default     = "t4g.large"
}

variable "instance-key-name" {
  description = "This sets the SSH Key used for the instance"
  type        = string
}