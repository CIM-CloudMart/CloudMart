# CloudMart Terraform Deployment Guide

This guide details how to plan and apply the AWS infrastructure and Kubernetes configuration for the CloudMart platform.

---

## 🛠️ Step 0: Bootstrap Remote State

```bash
# Navigate to the bootstrap directory
cd infra/bootstrap

# Initialize Terraform configuration
terraform init

# Apply and create the bucket and locking table
terraform apply -auto-approve
```

---

## 🚀 Step 1: Provision Core AWS Infrastructure

The `infra/terraform/eks/` directory provisions the underlying AWS infrastructure including the VPC, EKS cluster, node groups, databases, queues, container registries, and IAM roles.

```bash
# Navigate to the EKS infrastructure directory
cd ../terraform/eks

# Initialize Terraform configuration
terraform init

# Generate a preview of the changes
terraform plan -out=eks.tfplan

# Apply the approved changes
terraform apply eks.tfplan
```

---

## ☸️ Step 2: Configure Kubernetes & Helm

The `infra/terraform/k8s-config/` directory connects to the newly provisioned EKS cluster to configure namespaces, service accounts (with IRSA annotations), default network policies, and the AWS Load Balancer Controller.

> [!IMPORTANT]
> Step 1 (EKS core infrastructure provisioning) must be completely applied and active before starting Step 2.

```bash
# Navigate to the Kubernetes configuration directory
cd ../k8s-config

# Initialize Terraform configuration
terraform init

# Generate a preview plan
terraform plan -out=k8s.tfplan

# Apply the approved changes
terraform apply k8s.tfplan
```