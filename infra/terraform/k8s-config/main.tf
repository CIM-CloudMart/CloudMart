# ==================== Kubernetes Config Module ====================

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket         = "cloudmart-tfstate-${var.team}"
    key            = "cloudmart/eks/terraform.tfstate"
    region         = var.region
    dynamodb_table = "cloudmart-tfstate-lock"
  }
}

# ==================== Dynamic Providers configuration ====================

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
      command     = "aws"
    }
  }
}

# ==================== Namespaces ====================

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "cloudmart-prod"
    labels = {
      project     = "cloudmart"
      managed-by  = "terraform"
      environment = "prod"
    }
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "cloudmart-staging"
    labels = {
      project     = "cloudmart"
      managed-by  = "terraform"
      environment = "staging"
    }
  }
}

# ==================== Service Accounts (Production) ====================

resource "kubernetes_service_account" "product_prod" {
  metadata {
    name      = "product-service-sa"
    namespace = kubernetes_namespace.prod.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.product_service_role_arn_prod
    }
  }
}

resource "kubernetes_service_account" "order_prod" {
  metadata {
    name      = "order-service-sa"
    namespace = kubernetes_namespace.prod.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.order_service_role_arn_prod
    }
  }
}

resource "kubernetes_service_account" "user_prod" {
  metadata {
    name      = "user-service-sa"
    namespace = kubernetes_namespace.prod.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.user_service_role_arn_prod
    }
  }
}

resource "kubernetes_service_account" "notification_prod" {
  metadata {
    name      = "notification-service-sa"
    namespace = kubernetes_namespace.prod.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.notification_service_role_arn_prod
    }
  }
}

# ==================== Service Accounts (Staging) ====================

resource "kubernetes_service_account" "product_staging" {
  metadata {
    name      = "product-service-sa"
    namespace = kubernetes_namespace.staging.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.product_service_role_arn_staging
    }
  }
}

resource "kubernetes_service_account" "order_staging" {
  metadata {
    name      = "order-service-sa"
    namespace = kubernetes_namespace.staging.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.order_service_role_arn_staging
    }
  }
}

resource "kubernetes_service_account" "user_staging" {
  metadata {
    name      = "user-service-sa"
    namespace = kubernetes_namespace.staging.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.user_service_role_arn_staging
    }
  }
}

resource "kubernetes_service_account" "notification_staging" {
  metadata {
    name      = "notification-service-sa"
    namespace = kubernetes_namespace.staging.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.notification_service_role_arn_staging
    }
  }
}

# ==================== AWS Load Balancer Controller Helm Release ====================

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set {
    name  = "clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_name
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
    value = data.terraform_remote_state.eks.outputs.aws_load_balancer_controller_role_arn
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = data.terraform_remote_state.eks.outputs.vpc_id
  }
}

# ==================== Network Policies (Production) ====================

resource "kubernetes_network_policy" "default_deny_prod" {
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.prod.metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_dns_prod" {
  metadata {
    name      = "allow-dns-egress"
    namespace = kubernetes_namespace.prod.metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Egress"]
    egress {
      to {
        namespace_selector {}
      }
      ports {
        protocol = "UDP"
        port     = "53"
      }
      ports {
        protocol = "TCP"
        port     = "53"
      }
    }
  }
}

# ==================== Network Policies (Staging) ====================

resource "kubernetes_network_policy" "default_deny_staging" {
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.staging.metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_dns_staging" {
  metadata {
    name      = "allow-dns-egress"
    namespace = kubernetes_namespace.staging.metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Egress"]
    egress {
      to {
        namespace_selector {}
      }
      ports {
        protocol = "UDP"
        port     = "53"
      }
      ports {
        protocol = "TCP"
        port     = "53"
      }
    }
  }
}
