variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "limit_amount" {
  description = "The monthly budget limit amount in the specified unit"
  type        = string
  default     = "100"
}

variable "limit_unit" {
  description = "The unit of measurement for budget limit (e.g., USD)"
  type        = string
  default     = "USD"
}

variable "subscriber_emails" {
  description = "E-mail addresses to notify"
  type        = list(string)
  default     = ["admin@cloudmart.example"]
}
