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
