# Import blocks to associate pre-existing AWS resources with Terraform state

import {
  to = module.dynamodb_staging.aws_dynamodb_table.products
  id = "cloudmart-products-staging"
}

import {
  to = module.s3_staging.aws_s3_bucket.storage
  id = "cloudmart-storage-team-axel-staging"
}

import {
  to = module.s3_staging.aws_s3_bucket.failover_website
  id = "failover-cloudmart-staging-team-axel"
}

import {
  to = module.ecr_staging.aws_ecr_repository.repos["user-service"]
  id = "cloudmart-user-service-staging"
}

import {
  to = module.ecr_staging.aws_ecr_repository.repos["notification-service"]
  id = "cloudmart-notification-service-staging"
}

import {
  to = module.ecr_staging.aws_ecr_repository.repos["frontend"]
  id = "cloudmart-frontend-staging"
}

import {
  to = module.ecr_staging.aws_ecr_repository.repos["order-service"]
  id = "cloudmart-order-service-staging"
}

import {
  to = module.ecr_staging.aws_ecr_repository.repos["product-service"]
  id = "cloudmart-product-service-staging"
}

import {
  to = module.iam_staging.aws_iam_policy.aws_load_balancer_controller
  id = "arn:aws:iam::779417963796:policy/cloudmart-aws-load-balancer-controller-policy-staging"
}

import {
  to = module.iam_staging.aws_iam_role.github_actions
  id = "cloudmart-github-actions-role-staging"
}

import {
  to = module.monitoring_staging.aws_cloudwatch_log_group.service_logs["frontend"]
  id = "/cloudmart/frontend-staging"
}

import {
  to = module.monitoring_staging.aws_cloudwatch_log_group.service_logs["notification-service"]
  id = "/cloudmart/notification-service-staging"
}

import {
  to = module.monitoring_staging.aws_cloudwatch_log_group.service_logs["user-service"]
  id = "/cloudmart/user-service-staging"
}

import {
  to = module.monitoring_staging.aws_cloudwatch_log_group.service_logs["product-service"]
  id = "/cloudmart/product-service-staging"
}

import {
  to = module.monitoring_staging.aws_cloudwatch_log_group.service_logs["order-service"]
  id = "/cloudmart/order-service-staging"
}

import {
  to = module.rds_staging.aws_db_parameter_group.postgres
  id = "cloudmart-postgres-pg-staging"
}

import {
  to = module.secrets_manager_staging.aws_secretsmanager_secret.db
  id = "arn:aws:secretsmanager:ap-south-1:779417963796:secret:cloudmart-db-credentials-staging-iX91QA"
}

import {
  to = module.secrets_manager_staging.aws_secretsmanager_secret.jwt
  id = "arn:aws:secretsmanager:ap-south-1:779417963796:secret:cloudmart-jwt-secret-staging-CGGZ9U"
}

import {
  to = module.iam_staging.aws_iam_role.product_service
  id = "cloudmart-product-service-role-staging"
}

import {
  to = module.iam_staging.aws_iam_role.order_service
  id = "cloudmart-order-service-role-staging"
}

import {
  to = module.iam_staging.aws_iam_role.notification_service
  id = "cloudmart-notification-service-role-staging"
}

import {
  to = module.iam_staging.aws_iam_role.user_service
  id = "cloudmart-user-service-role-staging"
}

import {
  to = module.iam_staging.aws_iam_role.aws_load_balancer_controller
  id = "cloudmart-aws-load-balancer-controller-role-staging"
}
