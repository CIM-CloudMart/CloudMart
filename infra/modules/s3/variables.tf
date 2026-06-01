variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN for bucket encryption"
  type        = string
}

