output "node_security_group_id" {
  description = "The security group ID of EKS worker nodes"
  value       = module.eks.node_security_group_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "oidc_provider_url" {
  description = "The OIDC provider URL of the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}
