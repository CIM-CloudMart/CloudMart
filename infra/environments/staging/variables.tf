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
  default     = "t3.micro"
}

variable "use_fargate" {
  description = "Use EKS Fargate (0.25 vCPU per pod) instead of EC2 nodes (2 vCPU each)"
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "desired_node_count" {
  description = "EC2 worker nodes (only when use_fargate = false)"
  type        = number
  default     = 0
}

variable "enable_guardduty" {
  description = "Enable GuardDuty (off by default on free-tier accounts)"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "RDS backup days (free tier: max 1)"
  type        = number
  default     = 1
}

variable "owner_email" {
  description = "Owner email for mandatory cost/ownership tags"
  type        = string
  default     = "admin@cloudmart.example"
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ (cost optimization)"
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
  description = "Enable Web ACL creation (costs ~$25/month, not free-tier eligible)"
  type        = bool
  default     = false
}

variable "alb_dns_name" {
  description = "The DNS endpoint of the EKS ingress Application Load Balancer"
  type        = string
  default     = null
}

