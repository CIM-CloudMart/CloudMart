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

variable "private_data_subnet_ids" {
  description = "Subnet IDs for the private data tier"
  type        = list(string)
}

variable "eks_node_sg_id" {
  description = "Security group ID of EKS nodes"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN for database storage encryption"
  type        = string
}

