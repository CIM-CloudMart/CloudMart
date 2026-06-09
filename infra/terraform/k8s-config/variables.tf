variable "project" {
  description = "Project name"
  type        = string
  default     = "cloudmart"
}

variable "environment" {
  description = "Primary deployment environment"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "team" {
  description = "Team name for tagging and backend remote state naming"
  type        = string
  default     = "team-axel"
}

variable "owner_email" {
  description = "Owner email for mandatory tagging"
  type        = string
  default     = "admin@cloudmart.example"
}
