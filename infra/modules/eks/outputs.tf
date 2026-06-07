output "node_security_group_id" {
  description = "EKS node security group (EC2 mode only; null on Fargate-only)"
  value       = try(module.eks.node_security_group_id, module.eks.cluster_primary_security_group_id)
}

output "cluster_security_group_id" {
  description = "Primary cluster security group (use for RDS when on Fargate)"
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "oidc_provider_url" {
  description = "The OIDC provider URL of the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "uses_fargate" {
  description = "Whether the cluster uses Fargate instead of EC2 node groups"
  value       = var.use_fargate
}

output "cluster_endpoint" {
  description = "EKS Cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS Cluster CA certificate data"
  value       = module.eks.cluster_certificate_authority_data
}
