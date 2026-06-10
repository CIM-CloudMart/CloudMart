output "cluster_name" {
  description = "The name of the shared EKS cluster"
  value       = data.aws_eks_cluster.shared.name
}

output "cluster_security_group_id" {
  description = "Primary cluster security group"
  value       = data.aws_eks_cluster.shared.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_url" {
  description = "The OIDC provider URL of the EKS cluster"
  value       = data.aws_eks_cluster.shared.identity[0].oidc[0].issuer
}

output "cluster_endpoint" {
  description = "EKS Cluster API endpoint"
  value       = data.aws_eks_cluster.shared.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS Cluster CA certificate data"
  value       = data.aws_eks_cluster.shared.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider (for IRSA)"
  value       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.shared.identity[0].oidc[0].issuer, "https://", "")}"
}
