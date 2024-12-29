variable "region" {
  description = "Region to deploy rancher infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "ip-allowlist-additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
  default     = ["185.77.56.0/24"]
}

variable "rancher-secret-arn" {
  description = "Rancher Secret Data"
  type        = string
  default     = "arn:aws:secretsmanager:eu-west-2:281287281094:secret:rancher-QeIi1B"
}

variable "letsencrypt-email" {
  description = "Let's encrypt Email"
  type        = string
  default     = "martin@sarrionandia.co.uk"
}