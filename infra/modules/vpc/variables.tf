variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones / subnets to create"
  type        = number
  default     = 2
}

variable "vpc_cidr_prefix" {
  description = "CIDR prefix length for the VPC (e.g., 16 for /16)"
  type        = number
  default     = 16
}

variable "subnet_prefix_length" {
  description = "CIDR prefix length for each subnet (e.g., 20)"
  type        = number
  default     = 20
}
