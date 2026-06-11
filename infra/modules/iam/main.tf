# ==================== IAM Module ====================

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  oidc_provider = replace(var.oidc_url, "https://", "")
  account_id    = data.aws_caller_identity.current.account_id
  partition     = data.aws_partition.current.partition
  k8s_namespace = var.kubernetes_namespace != "" ? var.kubernetes_namespace : "cloudmart-${var.environment}"
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
      values = [
        "system:serviceaccount:cloudmart-prod:product-service-sa",
        "system:serviceaccount:cloudmart-staging:product-service-sa"
      ]
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

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [var.kms_key_arn]
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
      values = [
        "system:serviceaccount:cloudmart-prod:order-service-sa",
        "system:serviceaccount:cloudmart-staging:order-service-sa"
      ]
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
      "sqs:ReceiveMessage",
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
      values = [
        "system:serviceaccount:cloudmart-prod:notification-service-sa",
        "system:serviceaccount:cloudmart-staging:notification-service-sa"
      ]
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
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [var.dynamodb_events_table_arn]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"]
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
      values = [
        "system:serviceaccount:cloudmart-prod:user-service-sa",
        "system:serviceaccount:cloudmart-staging:user-service-sa"
      ]
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
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      var.db_secret_arn,
      var.jwt_secret_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [var.kms_key_arn]
  }
}


resource "aws_iam_role_policy" "user_service" {
  name   = "${var.project}-user-service-policy-${var.environment}"
  role   = aws_iam_role.user_service.id
  policy = data.aws_iam_policy_document.user_service_policy.json
}

# ==================== AWS Load Balancer Controller IAM Role ====================

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
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
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "${var.project}-aws-load-balancer-controller-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role.json
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.project}-aws-load-balancer-controller-policy-${var.environment}"
  path        = "/"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

# ==================== GitHub Actions IAM Role (OIDC) ====================

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:CIM-CloudMart/CloudMart:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project}-github-actions-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = ["arn:${local.partition}:ecr:${var.region}:${local.account_id}:repository/cloudmart-*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster"
    ]
    resources = ["arn:${local.partition}:eks:${var.region}:${local.account_id}:cluster/${var.cluster_name}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "wafv2:ListWebACLs"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "${var.project}-github-actions-policy-${var.environment}"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_policy.json
}

