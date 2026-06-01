# EKS Cluster + Node Groups (Skeleton Module)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = "${var.project}-eks-${var.environment}"
  cluster_version = "1.30"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_app_subnet_ids

  # Cluster IAM Role
  iam_role_name = "${var.project}-eks-cluster-role-${var.environment}"

  # Enable IRSA (IAM Roles for Service Accounts) - Mandatory for workload identity
  enable_irsa = true

  # Node Groups
  eks_managed_node_groups = {
    main = {
      name           = "main-node-group"
      instance_types = [var.node_instance_type]
      min_size       = var.desired_node_count
      max_size       = var.environment == "prod" ? 5 : 3
      desired_size   = var.desired_node_count

      # Required labels for scheduling
      labels = {
        Environment = var.environment
        Project     = var.project
      }
    }
  }

  # Cluster addons
  cluster_addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni = {}
  }
}
