variable "project" {
  description = "Project name"
  type        = string
  default     = "cloudmart"
}

variable "environment" {
  description = "Primary deployment environment (used for EKS name prefix)"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "team" {
  description = "Team name for tagging and S3 bucket naming"
  type        = string
  default     = "team-axel"
}

variable "owner_email" {
  description = "Owner email for mandatory cost/ownership tags"
  type        = string
  default     = "admin@cloudmart.example"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_type" {
  description = "Worker node instance type"
  type        = string
  default     = "t3.micro"
}

variable "use_fargate" {
  description = "Use EKS Fargate instead of EC2 nodes"
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = "EKS version"
  type        = string
  default     = "1.29"
}

variable "desired_node_count" {
  description = "EC2 worker nodes (only when use_fargate = false)"
  type        = number
  default     = 0
}

variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = false
}

variable "backup_retention_period_prod" {
  description = "RDS backup days for production"
  type        = number
  default     = 7
}

variable "backup_retention_period_staging" {
  description = "RDS backup days for staging"
  type        = number
  default     = 1
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ"
  type        = bool
  default     = true
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

variable "rds_instance_class" {
  description = "The database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_multi_az" {
  description = "Specifies if the RDS instance is Multi-AZ"
  type        = bool
  default     = false
}

variable "rds_max_allocated_storage" {
  description = "The upper limit for RDS storage autoscaling"
  type        = number
  default     = 20
}

variable "enable_waf" {
  description = "Enable Web ACL creation"
  type        = bool
  default     = false
}
