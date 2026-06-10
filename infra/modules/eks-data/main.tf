# Shared EKS cluster data source — looks up the existing "cloudmart" cluster
# Both staging and prod environments share this single cluster, separated by namespaces.

data "aws_eks_cluster" "shared" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}
