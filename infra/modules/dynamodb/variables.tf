variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "team" {
  description = "Team name for tagging"
  type        = string
  default     = "team-axel"
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN to use for server-side encryption"
  type        = string
  default     = null
}
