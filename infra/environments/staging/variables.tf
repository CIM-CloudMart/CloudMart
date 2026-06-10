variable "project" {
  description = "Project name"
  type        = string
  default     = "cloudmart"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "team" {
  description = "Team name (used for globally unique S3 bucket naming)"
  type        = string
  default     = "team-axel"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway"
  type        = bool
  default     = false
}

variable "from_email" {
  description = "SES sender email"
  type        = string
  default     = "no-reply@cloudmart.com"
}

variable "use_fargate" {
  description = "Deploy workloads on Fargate"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.27"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_node_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "enable_waf" {
  description = "Enable AWS WAF"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Root domain name for Route53"
  type        = string
  default     = "example.com"
}

variable "limit_amount" {
  description = "Budget limit amount"
  type        = number
  default     = 1000
}

variable "subscriber_emails" {
  description = "Emails to receive budget alerts"
  type        = list(string)
  default     = []
}

variable "enable_guardduty" {
  description = "Enable GuardDuty monitoring"
  type        = bool
  default     = false
}

variable "rds_multi_az" {
  description = "Whether the RDS instance should be Multi‑AZ in this environment"
  type        = bool
  default     = false
}

variable "rds_instance_class" {
  description = "The database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_max_allocated_storage" {
  description = "The upper limit for RDS storage autoscaling"
  type        = number
  default     = 20
}

variable "backup_retention_period_staging" {
  description = "Backup retention days for staging"
  type        = number
  default     = 7
}
