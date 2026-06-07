# ==================== IAM Module ====================

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  oidc_provider = replace(var.oidc_url, "https://", "")
  account_id    = data.aws_caller_identity.current.account_id
  partition     = data.aws_partition.current.partition
}

# ==================== Product Service IAM Role ====================

data "aws_iam_policy_document" "product_service_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.oidc_provider}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:cloudmart-${var.environment}:product-service-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "product_service" {
  name               = "${var.project}-product-service-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.product_service_assume_role.json
}

data "aws_iam_policy_document" "product_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [var.dynamodb_table_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      var.storage_bucket_arn,
      "${var.storage_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "product_service" {
  name   = "${var.project}-product-service-policy-${var.environment}"
  role   = aws_iam_role.product_service.id
  policy = data.aws_iam_policy_document.product_service_policy.json
}

# ==================== Order Service IAM Role ====================

data "aws_iam_policy_document" "order_service_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.oidc_provider}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:cloudmart-${var.environment}:order-service-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "order_service" {
  name               = "${var.project}-order-service-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.order_service_assume_role.json
}

data "aws_iam_policy_document" "order_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [var.sqs_queue_arn]
  }
}

resource "aws_iam_role_policy" "order_service" {
  name   = "${var.project}-order-service-policy-${var.environment}"
  role   = aws_iam_role.order_service.id
  policy = data.aws_iam_policy_document.order_service_policy.json
}

# ==================== Notification Service IAM Role ====================

data "aws_iam_policy_document" "notification_service_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.oidc_provider}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:cloudmart-${var.environment}:notification-service-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "notification_service" {
  name               = "${var.project}-notification-service-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.notification_service_assume_role.json
}

data "aws_iam_policy_document" "notification_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [var.sqs_queue_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = [var.ses_email_identity_arn]
  }
}

resource "aws_iam_role_policy" "notification_service" {
  name   = "${var.project}-notification-service-policy-${var.environment}"
  role   = aws_iam_role.notification_service.id
  policy = data.aws_iam_policy_document.notification_service_policy.json
}

# ==================== User Service IAM Role ====================

data "aws_iam_policy_document" "user_service_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.oidc_provider}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:cloudmart-${var.environment}:user-service-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "user_service" {
  name               = "${var.project}-user-service-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.user_service_assume_role.json
}

data "aws_iam_policy_document" "user_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.db_secret_arn]
  }
}

resource "aws_iam_role_policy" "user_service" {
  name   = "${var.project}-user-service-policy-${var.environment}"
  role   = aws_iam_role.user_service.id
  policy = data.aws_iam_policy_document.user_service_policy.json
}

