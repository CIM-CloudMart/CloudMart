# Staging environment resources

provider "aws" {
  alias  = "staging"
  region = var.region
}

module "vpc" {
  source             = "../../modules/vpc"
  project            = var.project
  environment        = "staging"
  vpc_cidr           = var.vpc_cidr
  region             = var.region
  team               = var.team
  cluster_name       = "cloudmart"
  single_nat_gateway = var.single_nat_gateway
  providers          = { aws = aws.staging }
}

module "kms" {
  source      = "../../modules/kms"
  project     = var.project
  environment = "staging"
  providers   = { aws = aws.staging }
}

module "ses" {
  source      = "../../modules/ses"
  project     = var.project
  environment = "staging"
  from_email  = var.from_email
  providers   = { aws = aws.staging }
}

module "eks" {
  source       = "../../modules/eks-data"
  cluster_name = "cloudmart"
  providers    = { aws = aws.staging }
}

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
  eks_cluster_sg_id       = null
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
