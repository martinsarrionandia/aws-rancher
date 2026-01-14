variable "subnet_cidr" {
  type = string
}

variable "domain_name" {
  description = "DNS Domain name for IAM policy creation"
  type        = string
}

variable "hostname" {
  description = "Hostname of the rancher server"
  type        = string
}

variable "ip_allowlist_additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
}

variable "rancher_secret_arn" {
  description = "AWS Secret Manager ARN for rancher passwords and secret data"
  type        = string
}

variable "letsencrypt_email" {
  description = "Let's encrypt email for certificate notification events"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t4g.large"
}

variable "instance_key_name" {
  description = "This sets the SSH Key used for the instance"
  type        = string
}