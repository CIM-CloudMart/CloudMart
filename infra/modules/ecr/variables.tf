variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "repository_names" {
  description = "List of repository names to create"
  type        = list(string)
  default = [
    "product-service",
    "order-service",
    "user-service",
    "notification-service",
    "frontend"
  ]
}

variable "team" {
  description = "Team name for tagging"
  type        = string
  default     = "team-axel"
}

variable "owner_email" {
  description = "Owner email for tagging and notifications"
  type        = string
  default     = "admin@cloudmart.example"
}

variable "kms_key_id" {
  description = "Optional KMS key id to use for repository encryption (customer-managed). If null, AES256 is used."
  type        = string
  default     = null
}
