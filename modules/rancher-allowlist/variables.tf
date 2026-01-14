variable "ip_allowlist_additional" {
  description = "Additional IP ranges for IP allowlist"
  type        = list(any)
  default     = []
}

variable "instance_ids" {
  description = "List of instances to apply the allow list"
  type        = list(any)
}

variable "env_name" {
  description = "Name of the environment"
  type        = string
}