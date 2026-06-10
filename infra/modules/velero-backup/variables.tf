variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "team" {
  description = "Team name (used for globally unique S3 bucket naming)"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN for S3 bucket encryption"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider for IRSA"
  type        = string
}

variable "oidc_provider_url_stripped" {
  description = "OIDC provider URL without https:// prefix (used in IAM trust policy conditions)"
  type        = string
}
