# ==================== CloudMart Staging Infrastructure ====================

data "aws_vpc" "prod" {
  filter {
    name   = "tag:Name"
    values = ["cloudmart-vpc-prod"]
  }
}

data "aws_subnets" "prod_private_app" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.prod.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["private-app"]
  }
}

data "aws_subnets" "prod_private_data" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.prod.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["private-data"]
  }
}

data "aws_security_group" "prod_bastion" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.prod.id]
  }
  filter {
    name   = "tag:Name"
    values = ["cloudmart-bastion-sg-prod"]
  }
}

data "aws_eks_cluster" "prod" {
  name = "cloudmart-eks-prod"
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

module "iam" {
  source                 = "../../modules/iam"
  project                = var.project
  environment            = var.environment
  cluster_name           = data.aws_eks_cluster.prod.name
  oidc_url               = data.aws_eks_cluster.prod.identity[0].oidc[0].issuer
  kubernetes_namespace   = "staging"
  dynamodb_table_arn     = module.dynamodb.dynamodb_table_arn
  sqs_queue_arn          = module.sqs.queue_arn
  storage_bucket_arn     = module.s3.bucket_arn
  ses_email_identity_arn = module.ses.ses_email_identity_arn
  db_secret_arn          = module.secrets_manager.secret_arn
  jwt_secret_arn         = module.secrets_manager.jwt_secret_arn
  kms_key_arn            = module.kms.key_arn
  region                 = var.region
}

module "rds" {
  source                  = "../../modules/rds"
  project                 = var.project
  environment             = var.environment
  vpc_id                  = data.aws_vpc.prod.id
  private_data_subnet_ids = data.aws_subnets.prod_private_data.ids
  eks_cluster_sg_id       = data.aws_eks_cluster.prod.vpc_config[0].cluster_security_group_id
  kms_key_arn             = module.kms.key_arn
  db_secret_arn           = module.secrets_manager.secret_arn
  db_password             = module.secrets_manager.db_password
  db_username             = module.secrets_manager.db_username
  instance_class          = var.rds_instance_class
  multi_az                = var.rds_multi_az
  max_allocated_storage   = var.rds_max_allocated_storage
  backup_retention_period = var.backup_retention_period
  bastion_sg_id           = data.aws_security_group.prod_bastion.id
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
  vpc_id              = data.aws_vpc.prod.id
  enable_guardduty    = var.enable_guardduty
  enable_security_hub = false
}
