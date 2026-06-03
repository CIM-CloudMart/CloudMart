# ==================== CloudMart Staging Infrastructure ====================

module "vpc" {
  source      = "../../modules/vpc"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  region      = var.region
  team        = var.team
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
  kms_key_id  = module.kms.key_id
}

module "ses" {
  source      = "../../modules/ses"
  project     = var.project
  environment = var.environment
  from_email  = var.from_email
}

module "eks" {
  source                 = "../../modules/eks"
  project                = var.project
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  node_instance_type     = var.node_instance_type
  desired_node_count     = var.desired_node_count
  team                   = var.team
  kms_key_id             = module.kms.key_arn
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
}

module "iam" {
  source                 = "../../modules/iam"
  project                = var.project
  environment            = var.environment
  cluster_name           = module.eks.cluster_name
  oidc_url               = module.eks.oidc_provider_url
  dynamodb_table_arn     = module.dynamodb.dynamodb_table_arn
  sqs_queue_arn          = module.sqs.queue_arn
  storage_bucket_arn     = module.s3.bucket_arn
  ses_email_identity_arn = module.ses.ses_email_identity_arn
}

module "rds" {
  source                  = "../../modules/rds"
  project                 = var.project
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  eks_node_sg_id          = module.eks.node_security_group_id
  kms_key_arn             = module.kms.key_arn
  db_secret_arn           = module.secrets_manager.secret_arn
}

module "waf" {
  source      = "../../modules/waf"
  project     = var.project
  environment = var.environment
}

module "route53" {
  source      = "../../modules/route53"
  project     = var.project
  environment = var.environment
  domain_name = var.domain_name
}

module "budget" {
  source            = "../../modules/budget"
  project           = var.project
  environment       = var.environment
  limit_amount      = var.limit_amount
  subscriber_emails = var.subscriber_emails
}

module "monitoring" {
  source      = "../../modules/monitoring"
  project     = var.project
  environment = var.environment
}

module "security" {
  source      = "../../modules/security"
  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}
