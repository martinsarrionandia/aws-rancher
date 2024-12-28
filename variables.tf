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