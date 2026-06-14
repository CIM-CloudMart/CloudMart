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
  default     = "team-axel-8"
}

variable "kms_key_id" {
  description = "Optional KMS key id for server-side encryption of the SQS queues"
  type        = string
  default     = null
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the SQS queue in seconds"
  type        = number
  default     = 30
}

variable "redrive_max_receive_count" {
  description = "Maximum receives before message sent to DLQ"
  type        = number
  default     = 5
}
