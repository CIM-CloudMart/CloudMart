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

variable "eks_cluster_sg_id" {
  description = "EKS cluster security group ID (Fargate pods or worker nodes)"
  type        = string
  default     = null
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

variable "instance_class" {
  description = "The database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is Multi-AZ"
  type        = bool
  default     = true
}

variable "max_allocated_storage" {
  description = "The upper limit for RDS storage autoscaling"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.13"
}

variable "backup_retention_period" {
  description = "Backup retention days derived from disaster-recovery rpo_backup_hours (converted to days)"
  type        = number
}




variable "bastion_sg_id" {
  description = "The security group ID of the bastion host to allow database access"
  type        = string
  default     = null
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "db_subnet_group_name_suffix" {
  description = "Optional suffix for the DB subnet group name"
  type        = string
  default     = ""
}

