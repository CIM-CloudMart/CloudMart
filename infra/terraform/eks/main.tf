# ==================== CloudMart Base AWS Infrastructure ====================

module "vpc" {
  source             = "../../modules/vpc"
  project            = var.project
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  region             = var.region
  team               = var.team
  cluster_name       = "cloudmart"
  single_nat_gateway = var.single_nat_gateway
}

module "kms" {
  source      = "../../modules/kms"
  project     = var.project
  environment = var.environment
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
  cluster_name                    = "cloudmart"
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

module "waf" {
  source      = "../../modules/waf"
  project     = var.project
  environment = var.environment
  enable_waf  = var.enable_waf
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

module "security" {
  source              = "../../modules/security"
  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  enable_guardduty    = var.enable_guardduty
  enable_security_hub = false
}

module "disaster_recovery" {
  source = "../../modules/disaster-recovery"
}


# ==================== Production Environment Resources ====================

module "secrets_manager_prod" {
  source      = "../../modules/secrets-manager"
  project     = var.project
  environment = "prod"
  kms_key_id  = module.kms.key_id
}

module "s3_prod" {
  source      = "../../modules/s3"
  project     = var.project
  environment = "prod"
  team        = var.team
  kms_key_arn = module.kms.key_arn
}

module "dynamodb_prod" {
  source      = "../../modules/dynamodb"
  project     = var.project
  environment = "prod"
  team        = var.team
  kms_key_arn = module.kms.key_arn
}

module "ecr_prod" {
  source      = "../../modules/ecr"
  project     = var.project
  environment = "prod"
  team        = var.team
  kms_key_id  = module.kms.key_id
}

module "sqs_prod" {
  source      = "../../modules/sqs"
  project     = var.project
  environment = "prod"
  team        = var.team
  kms_key_id  = null
}

module "rds_prod" {
  source                  = "../../modules/rds"
  project                 = var.project
  environment             = "prod"
  vpc_id                  = module.vpc.vpc_id
  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  eks_cluster_sg_id       = module.eks.cluster_security_group_id
  kms_key_arn             = module.kms.key_arn
  db_secret_arn           = module.secrets_manager_prod.secret_arn
  db_password             = module.secrets_manager_prod.db_password
  db_username             = module.secrets_manager_prod.db_username
  instance_class          = var.rds_instance_class
  multi_az                = var.rds_multi_az
  max_allocated_storage   = var.rds_max_allocated_storage
  backup_retention_period = var.backup_retention_period_prod
  bastion_sg_id           = module.vpc.bastion_security_group_id

}

module "iam_prod" {
  source                 = "../../modules/iam"
  project                = var.project
  environment            = "prod"
  cluster_name           = module.eks.cluster_name
  oidc_url               = module.eks.oidc_provider_url
  kubernetes_namespace   = "cloudmart-prod"
  dynamodb_table_arn     = module.dynamodb_prod.dynamodb_table_arn
  sqs_queue_arn          = module.sqs_prod.queue_arn
  storage_bucket_arn     = module.s3_prod.bucket_arn
  ses_email_identity_arn = module.ses.ses_email_identity_arn
  db_secret_arn          = module.secrets_manager_prod.secret_arn
  jwt_secret_arn         = module.secrets_manager_prod.jwt_secret_arn
  kms_key_arn            = module.kms.key_arn
  region                 = var.region
}

module "monitoring_prod" {
  source            = "../../modules/monitoring"
  project           = var.project
  environment       = "prod"
  sqs_queue_name    = module.sqs_prod.queue_name
  subscriber_emails = var.subscriber_emails
}

# ==================== Staging Environment Resources ====================

module "secrets_manager_staging" {
  source      = "../../modules/secrets-manager"
  project     = var.project
  environment = "staging"
  kms_key_id  = module.kms.key_id
  providers   = { aws = aws.staging }
}

module "s3_staging" {
  source      = "../../modules/s3"
  project     = var.project
  environment = "staging"
  team        = var.team
  kms_key_arn = module.kms.key_arn
  providers   = { aws = aws.staging }
}

module "dynamodb_staging" {
  source      = "../../modules/dynamodb"
  project     = var.project
  environment = "staging"
  team        = var.team
  kms_key_arn = module.kms.key_arn
  providers   = { aws = aws.staging }
}

module "ecr_staging" {
  source      = "../../modules/ecr"
  project     = var.project
  environment = "staging"
  team        = var.team
  kms_key_id  = module.kms.key_id
  providers   = { aws = aws.staging }
}

module "sqs_staging" {
  source      = "../../modules/sqs"
  project     = var.project
  environment = "staging"
  team        = var.team
  kms_key_id  = null
  providers   = { aws = aws.staging }
}

module "rds_staging" {
  source                  = "../../modules/rds"
  project                 = var.project
  environment             = "staging"
  vpc_id                  = module.vpc.vpc_id
  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  eks_cluster_sg_id       = module.eks.cluster_security_group_id
  kms_key_arn             = module.kms.key_arn
  db_secret_arn           = module.secrets_manager_staging.secret_arn
  db_password             = module.secrets_manager_staging.db_password
  db_username             = module.secrets_manager_staging.db_username
  instance_class          = var.rds_instance_class
  multi_az                = var.rds_multi_az
  max_allocated_storage   = var.rds_max_allocated_storage
  backup_retention_period = var.backup_retention_period_staging
  bastion_sg_id           = module.vpc.bastion_security_group_id
  providers               = { aws = aws.staging }
}

module "iam_staging" {
  source                 = "../../modules/iam"
  project                = var.project
  environment            = "staging"
  cluster_name           = module.eks.cluster_name
  oidc_url               = module.eks.oidc_provider_url
  kubernetes_namespace   = "cloudmart-staging"
  dynamodb_table_arn     = module.dynamodb_staging.dynamodb_table_arn
  sqs_queue_arn          = module.sqs_staging.queue_arn
  storage_bucket_arn     = module.s3_staging.bucket_arn
  ses_email_identity_arn = module.ses.ses_email_identity_arn
  db_secret_arn          = module.secrets_manager_staging.secret_arn
  jwt_secret_arn         = module.secrets_manager_staging.jwt_secret_arn
  kms_key_arn            = module.kms.key_arn
  region                 = var.region
  providers              = { aws = aws.staging }
}

module "monitoring_staging" {
  source            = "../../modules/monitoring"
  project           = var.project
  environment       = "staging"
  sqs_queue_name    = module.sqs_staging.queue_name
  subscriber_emails = var.subscriber_emails
  providers         = { aws = aws.staging }
}
