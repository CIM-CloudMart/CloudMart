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

variable "db_secret_arn" {
  description = "Optional ARN of a Secrets Manager secret containing DB credentials (username/password)"
  type        = string
  default     = null
}

variable "db_username" {
  description = "Fallback DB username if no Secrets Manager secret is provided"
  type        = string
  default     = "cloudmartadmin"
}

