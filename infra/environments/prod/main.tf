# ==================== CloudMart Production Infrastructure ====================
module "vpc" {
  source             = "../../modules/vpc"
  project            = var.project
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  region             = var.region
  team               = var.team
  cluster_name       = "${var.project}-eks-${var.environment}"
  single_nat_gateway = var.single_nat_gateway
}

module "kms" {
  source      = "../../modules/kms"
  project     = var.project
  environment = var.environment
}

module "secrets_manager" {
  source      = "../../modules/secrets-manager"
  project     = var.project
  environment = var.environment
  kms_key_id  = module.kms.key_id
}

module "s3" {
  source      = "../../modules/s3"
  project     = var.project
  environment = var.environment
  team        = var.team
  kms_key_arn = module.kms.key_arn
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  project     = var.project
  environment = var.environment
  team        = var.team
  kms_key_arn = module.kms.key_arn
}

module "ecr" {
  source      = "../../modules/ecr"
  project     = var.project
  environment = var.environment
  team        = var.team
  kms_key_id  = module.kms.key_id
}

module "sqs" {
  source      = "../../modules/sqs"
  project     = var.project
  environment = var.environment
  team        = var.team
  kms_key_id  = null
}

module "ses" {
  source      = "../../modules/ses"
  project     = var.project
  environment = var.environment
  from_email  = var.from_email
}

module "eks" {
  source                          = "../../modules/eks"
  project                         = var.project
  environment                     = var.environment
  vpc_id                          = module.vpc.vpc_id
  private_app_subnet_ids          = module.vpc.private_app_subnet_ids
  use_fargate                     = var.use_fargate
  kubernetes_version              = var.kubernetes_version
  node_instance_type              = var.node_instance_type
  desired_node_count              = var.desired_node_count
  team                            = var.team
  kms_key_id                      = module.kms.key_arn
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
}

module "iam" {
  source                 = "../../modules/iam"
  project                = var.project
  environment            = var.environment
  cluster_name           = module.eks.cluster_name
  oidc_url               = module.eks.oidc_provider_url
  kubernetes_namespace   = "production"
  dynamodb_table_arn     = module.dynamodb.dynamodb_table_arn
  sqs_queue_arn          = module.sqs.queue_arn
  storage_bucket_arn     = module.s3.bucket_arn
  ses_email_identity_arn = module.ses.ses_email_identity_arn
  db_secret_arn          = module.secrets_manager.secret_arn
  jwt_secret_arn         = module.secrets_manager.jwt_secret_arn
  kms_key_arn            = module.kms.key_arn
  region                 = var.region
}

data "aws_caller_identity" "current" {}

locals {
  github_actions_roles = {
    prod    = module.iam.github_actions_role_arn
    staging = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cloudmart-github-actions-role-staging"
    cicd    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ci-cd"
  }
}

resource "aws_eks_access_entry" "github_actions" {
  for_each          = local.github_actions_roles
  cluster_name      = module.eks.cluster_name
  principal_arn     = each.value
  kubernetes_groups = []
}

resource "aws_eks_access_policy_association" "github_actions" {
  for_each      = local.github_actions_roles
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}


module "rds" {
  source                  = "../../modules/rds"
  project                 = var.project
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  eks_cluster_sg_id       = module.eks.cluster_security_group_id
  kms_key_arn             = module.kms.key_arn
  db_secret_arn           = module.secrets_manager.secret_arn
  db_password             = module.secrets_manager.db_password
  db_username             = module.secrets_manager.db_username
  instance_class          = var.rds_instance_class
  multi_az                = var.rds_multi_az
  max_allocated_storage   = var.rds_max_allocated_storage
  backup_retention_period = var.backup_retention_period
  bastion_sg_id           = module.vpc.bastion_security_group_id
}

module "waf" {
  source      = "../../modules/waf"
  project     = var.project
  environment = var.environment
  enable_waf  = var.enable_waf
}


module "route53" {
  source                     = "../../modules/route53"
  project                    = var.project
  environment                = var.environment
  domain_name                = var.domain_name
  alb_dns_name               = var.alb_dns_name
  failover_s3_website_domain = module.s3.failover_website_endpoint
}

module "budget" {
  source            = "../../modules/budget"
  project           = var.project
  environment       = var.environment
  limit_amount      = var.limit_amount
  subscriber_emails = var.subscriber_emails
}

module "monitoring" {
  source            = "../../modules/monitoring"
  project           = var.project
  environment       = var.environment
  sqs_queue_name    = module.sqs.queue_name
  subscriber_emails = var.subscriber_emails
}


module "security" {
  source              = "../../modules/security"
  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  enable_guardduty    = var.enable_guardduty
  enable_security_hub = false
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam.aws_load_balancer_controller_role_arn
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [module.eks, module.iam]
}

resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno"
  chart            = "kyverno"
  version          = "3.2.6"
  namespace        = "kyverno"
  create_namespace = true

  set {
    name  = "crds.install"
    value = "true"
  }

  depends_on = [module.eks]
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
    labels = {
      environment = "staging"
    }
  }
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
    labels = {
      environment = "production"
    }
  }
}

