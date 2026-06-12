import {
  to = module.core.module.iam.aws_iam_role.product_service
  id = "cloudmart-product-service-role-prod"
}

import {
  to = module.core.module.iam.aws_iam_role.order_service
  id = "cloudmart-order-service-role-prod"
}

import {
  to = module.core.module.iam.aws_iam_role.notification_service
  id = "cloudmart-notification-service-role-prod"
}

import {
  to = module.core.module.iam.aws_iam_role.user_service
  id = "cloudmart-user-service-role-prod"
}

import {
  to = module.core.module.iam.aws_iam_role.aws_load_balancer_controller
  id = "cloudmart-aws-load-balancer-controller-role-prod"
}

import {
  to = module.core.module.iam.aws_iam_policy.aws_load_balancer_controller
  id = "arn:aws:iam::779417963796:policy/cloudmart-aws-load-balancer-controller-policy-prod"
}

import {
  to = module.core.module.iam.aws_iam_role.github_actions
  id = "cloudmart-github-actions-role-prod"
}

import {
  to = module.core.module.monitoring.aws_cloudwatch_log_group.service_logs["product-service"]
  id = "/cloudmart/product-service-prod"
}

import {
  to = module.core.module.monitoring.aws_cloudwatch_log_group.service_logs["notification-service"]
  id = "/cloudmart/notification-service-prod"
}

import {
  to = module.core.module.monitoring.aws_cloudwatch_log_group.service_logs["order-service"]
  id = "/cloudmart/order-service-prod"
}

import {
  to = module.core.module.monitoring.aws_cloudwatch_log_group.service_logs["frontend"]
  id = "/cloudmart/frontend-prod"
}

import {
  to = module.core.module.monitoring.aws_cloudwatch_log_group.service_logs["user-service"]
  id = "/cloudmart/user-service-prod"
}

import {
  to = module.core.module.rds.aws_db_parameter_group.postgres
  id = "cloudmart-postgres-pg-prod"
}
