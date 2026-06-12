variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the hosted zone"
  type        = string
  default     = "cloudmart.example"
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB from ingress"
  type        = string
  default     = null
}

variable "failover_s3_website_domain" {
  description = "The S3 website endpoint domain"
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  description = "Existing Route53 Hosted Zone ID for failover records"
  type        = string
  default     = null
}
