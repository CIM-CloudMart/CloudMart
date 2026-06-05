variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "secret_name" {
  description = "Logical name for the secret (short)"
  type        = string
  default     = "db-credentials"
}

variable "username" {
  description = "Username to store in the secret"
  type        = string
  default     = "cloudmartadmin"
}

variable "kms_key_id" {
  description = "Optional KMS key id to encrypt the secret"
  type        = string
  default     = null
}

variable "rotation_enabled" {
  description = "Whether to enable rotation (requires rotation Lambda setup)"
  type        = bool
  default     = false
}
