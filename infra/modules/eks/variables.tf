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

variable "kms_key_id" {
  description = "Optional KMS key id to encrypt Kubernetes secrets and other cluster resources"
  type        = string
  default     = null
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API server should be publicly accessible"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS API server should be accessible from within the VPC"
  type        = bool
  default     = true
}
