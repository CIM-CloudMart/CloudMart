# EKS Cluster + Node Groups (Skeleton Module)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.project}-eks-${var.environment}"
  kubernetes_version = "1.30"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_app_subnet_ids

  # Cluster IAM Role
  iam_role_name = "${var.project}-eks-cluster-role-${var.environment}"

  # Control API endpoint accessibility
  endpoint_public_access  = var.cluster_endpoint_public_access
  endpoint_private_access = var.cluster_endpoint_private_access

  # KMS Key Management
  create_kms_key = false

  # Enable KMS encryption for secrets if provided
  encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_id
  }

  # Node Groups
  eks_managed_node_groups = {
    main = {
      name                 = "main-node-group"
      instance_types       = [var.node_instance_type]
      min_size             = var.desired_node_count
      max_size             = var.environment == "prod" ? 5 : 3
      desired_size         = var.desired_node_count
      bootstrap_extra_args = "--use-max-pods false --kubelet-extra-args '--max-pods=110'"

      # Required labels for scheduling
      labels = {
        Environment = var.environment
        Project     = var.project
      }
    }
  }

  # Cluster addons
  addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni = {}
  }
}
