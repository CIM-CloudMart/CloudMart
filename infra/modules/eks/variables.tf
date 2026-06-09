variable "project" {
  description = "Project name"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster Name override"
  type        = string
  default     = null
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
  description = "Subnet IDs for EKS (Fargate pods and/or worker nodes)"
  type        = list(string)
}

variable "node_instance_type" {
  description = "Worker node instance type (only when use_fargate = false)"
  type        = string
  default     = "t3.micro"
}

variable "desired_node_count" {
  description = "Worker node count (only when use_fargate = false)"
  type        = number
  default     = 0
}

variable "use_fargate" {
  description = "Run workloads on EKS Fargate (0.25 vCPU min per pod) instead of EC2 nodes"
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version (upgrade one minor version at a time on existing clusters)"
  type        = string
  default     = "1.33"
}

variable "team" {
  description = "Team name"
  type        = string
}

variable "kms_key_id" {
  description = "Optional KMS key ARN for Kubernetes secrets encryption"
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
