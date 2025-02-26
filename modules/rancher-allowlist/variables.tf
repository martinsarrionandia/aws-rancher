variable "ip-allowlist-additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
  default     = []
}

variable "instance-ids" {
  description = "List of instances to apply the allow list"
  type        = list(any)
}