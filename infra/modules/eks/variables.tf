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

variable "private_app_subnet_ids" {
  description = "Subnet IDs for the EKS worker nodes"
  type        = list(string)
}

variable "node_instance_type" {
  description = "Worker node instance type"
  type        = string
}

variable "desired_node_count" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "team" {
  description = "Team name"
  type        = string
}
