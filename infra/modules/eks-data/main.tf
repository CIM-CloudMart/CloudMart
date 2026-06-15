# Shared EKS cluster data source — looks up the existing "cloudmart" cluster
# Both staging and prod environments share this single cluster, separated by namespaces.

data "aws_eks_cluster" "shared" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "shared" {
  url = data.aws_eks_cluster.shared.identity[0].oidc[0].issuer
}
