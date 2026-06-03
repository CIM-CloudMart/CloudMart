variable "project" {
  description = "Project name"
  type        = string
  default     = "cloudmart"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "team" {
  description = "Team name"
  type        = string
  default     = "team-axel"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_type" {
  description = "Worker node instance type"
  type        = string
  default     = "t3.medium"
}

variable "desired_node_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "from_email" {
  description = "SES verified sender email address"
  type        = string
  default     = "noreply@cloudmart.example"
}

variable "domain_name" {
  description = "Primary domain name for the hosted zone"
  type        = string
  default     = "cloudmart.example"
}

variable "limit_amount" {
  description = "The monthly budget limit amount in USD"
  type        = string
  default     = "100"
}

variable "subscriber_emails" {
  description = "E-mail addresses to notify for budget alarms"
  type        = list(string)
  default     = ["admin@cloudmart.example"]
}
