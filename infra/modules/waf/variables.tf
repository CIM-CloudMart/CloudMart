variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "enable_waf" {
  description = "Enable Web ACL creation (not free-tier eligible)"
  type        = bool
  default     = false
}

