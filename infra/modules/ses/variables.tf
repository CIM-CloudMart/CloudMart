variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "from_email" {
  description = "SES verified sender email address"
  type        = string
  default     = "tradeasy.official01@gmail.com"
}
