variable "env-name" {
  description = "Name of the environment"
  type        = string
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