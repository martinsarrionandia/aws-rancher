variable "ip-allowlist-additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
  default     = ["185.77.56.105/24"]
}