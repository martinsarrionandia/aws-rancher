variable "ip-whitelist-additional" {
  description = "Additional IP ranges for IP whitelist"
  type        = list(any)
  default     = ["10.1.0.1/32"]
}