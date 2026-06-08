variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "enable_guardduty" {
  description = "Enable GuardDuty (requires paid/subscribed account)"
  type        = bool
  default     = false
}

variable "subscriber_emails" {
  description = "Emails to subscribe to security alarms"
  type        = list(string)
  default     = ["admin@cloudmart.example"]
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = false
}

