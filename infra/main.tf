# Core infrastructure modules

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  region      = var.region
  team        = var.team
  cluster_name = "cloudmart"
  single_nat_gateway = var.single_nat_gateway
}

module "kms" {
  source      = "./modules/kms"
  project     = var.project
  environment = var.environment
}

module "ses" {
  source      = "./modules/ses"
  project     = var.project
  environment = var.environment
  from_email  = var.from_email
}

module "eks" {
  source                  = "./modules/eks"
  project                 = var.project
  environment             = var.environment
  cluster_name            = "cloudmart"
  vpc_id                  = module.vpc.vpc_id
  private_app_subnet_ids  = module.vpc.private_app_subnet_ids
  use_fargate             = var.use_fargate
  kubernetes_version      = var.kubernetes_version
  node_instance_type      = var.node_instance_type
  desired_node_count      = var.desired_node_count
  team                    = var.team
  kms_key_id              = module.kms.key_arn
  admin_principal_arn     = var.admin_principal_arn
}

module "waf" {
  source      = "./modules/waf"
  project     = var.project
  environment = var.environment
  enable_waf  = var.enable_waf
}

module "route53" {
  source                     = "./modules/route53"
  project                    = var.project
  environment                = var.environment
  domain_name                = var.domain_name
  alb_dns_name               = var.alb_dns_name
  failover_s3_website_domain = "s3-website.${var.region}.amazonaws.com"
}

module "budget" {
  source            = "./modules/budget"
  project           = var.project
  environment       = var.environment
  limit_amount      = var.limit_amount
  subscriber_emails = var.subscriber_emails
}

module "security" {
  source              = "./modules/security"
  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  enable_guardduty    = var.enable_guardduty
  enable_security_hub = false
}

module "disaster_recovery" {
  source = "./modules/disaster-recovery"
}

module "secrets_manager" {
  source      = "./modules/secrets-manager"
  project     = var.project
  environment = var.environment
  kms_key_id  = module.kms.key_id
}

module "s3" {
  source      = "./modules/s3"
  project     = var.project
  environment = var.environment
  team        = var.team
  kms_key_arn = module.kms.key_arn
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  project     = var.project
  environment = var.environment
  team        = var.team
  kms_key_arn = module.kms.key_arn
}

module "ecr" {
  source      = "./modules/ecr"
  project     = var.project
  environment = var.environment
  team        = var.team
  kms_key_id  = module.kms.key_id
}

module "sqs" {
  source      = "./modules/sqs"
  project     = var.project
  environment = var.environment
  team        = var.team
  kms_key_id  = null
}

module "rds" {
  source                  = "./modules/rds"
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

module "iam" {
  source                 = "./modules/iam"
  project                = var.project
  environment            = var.environment
  cluster_name           = module.eks.cluster_name
  oidc_url               = module.eks.oidc_provider_url
  kubernetes_namespace   = "cloudmart-${var.environment}"
  dynamodb_table_arn     = module.dynamodb.dynamodb_table_arn
  dynamodb_events_table_arn = module.dynamodb.dynamodb_events_table_arn
  sqs_queue_arn          = module.sqs.queue_arn
  storage_bucket_arn     = module.s3.bucket_arn
  ses_email_identity_arn = module.ses.ses_email_identity_arn
  db_secret_arn          = module.secrets_manager.secret_arn
  jwt_secret_arn         = module.secrets_manager.jwt_secret_arn
  kms_key_arn            = module.kms.key_arn
  region                 = var.region
}

module "monitoring" {
  source            = "./modules/monitoring"
  project           = var.project
  environment       = var.environment
  sqs_queue_name    = module.sqs.queue_name
  subscriber_emails = var.subscriber_emails
}

data "aws_caller_identity" "current" {}

locals {
  github_actions_roles = merge(
    {
      prod = module.iam.github_actions_role_arn
    },
    var.cicd_role_arn != null && var.cicd_role_arn != "" ? { cicd = var.cicd_role_arn } : {}
  )
}

resource "aws_eks_access_entry" "github_actions" {
  for_each          = local.github_actions_roles
  cluster_name      = module.eks.cluster_name
  principal_arn     = each.value
  kubernetes_groups = []
  depends_on        = [module.iam]
}

resource "aws_eks_access_policy_association" "github_actions" {
  for_each      = local.github_actions_roles
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
  depends_on    = [module.iam]
}
