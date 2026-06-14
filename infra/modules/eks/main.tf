# EKS Cluster — Fargate-first for free tier / low vCPU quota
data "aws_caller_identity" "current" {}

locals {
  caller_arn = data.aws_caller_identity.current.arn
  # STS assumed roles return arn:aws:sts::... which is invalid for access entries.
  # Convert to the corresponding IAM role ARN if necessary.
  resolved_admin_arn = length(regexall("^arn:aws:sts::", local.caller_arn)) > 0 ? replace(
    local.caller_arn,
    "/^arn:aws:sts::(\\d+):assumed-role/(.+)/[^/]+$/",
    "arn:aws:iam::$1:role/$2"
  ) : local.caller_arn
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name != null ? var.cluster_name : "${var.project}-eks-${var.environment}"
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_app_subnet_ids

  force_update_version = false

  iam_role_name = "${var.project}-eks-cluster-role-${var.environment}"

  endpoint_public_access  = var.cluster_endpoint_public_access
  endpoint_private_access = var.cluster_endpoint_private_access

  create_kms_key = false

  enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


  encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_id
  }

  # Fargate: 0.25 vCPU minimum per pod — does not consume EC2 Standard vCPU quota
  fargate_profiles = var.use_fargate ? {
    kube_system = {
      name = "kube-system"
      selectors = [
        { namespace = "kube-system" }
      ]
    }
    cloudmart = {
      name = "cloudmart"
      selectors = [
        { namespace = "cloudmart-prod" },
        { namespace = "cloudmart-staging" }
      ]
    }
    external_secrets = {
      name = "external-secrets"
      selectors = [
        { namespace = "external-secrets" }
      ]
    }
    amazon_cloudwatch = {
      name = "amazon-cloudwatch"
      selectors = [
        { namespace = "amazon-cloudwatch" }
      ]
    }
    kyverno = {
      name = "kyverno"
      selectors = [
        { namespace = "kyverno" }
      ]
    }
    keda = {
      name = "keda"
      selectors = [
        { namespace = "keda" }
      ]
    }
  } : {}

  eks_managed_node_groups = var.use_fargate ? {} : {
    main = {
      name            = "main"
      use_name_prefix = false
      instance_types  = [var.node_instance_type]
      min_size        = 2
      max_size        = 5
      desired_size    = var.desired_node_count
      capacity_type   = "ON_DEMAND"

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }

      labels = {
        Environment = var.environment
        Project     = var.project
      }
    }
  }

  addons = var.use_fargate ? {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
    amazon-cloudwatch-observability = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    } : {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
    amazon-cloudwatch-observability = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  access_entries = {
    admin = {
      kubernetes_groups = []
      principal_arn     = var.admin_principal_arn != null && var.admin_principal_arn != "" ? var.admin_principal_arn : local.resolved_admin_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
