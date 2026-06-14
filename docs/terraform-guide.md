# CloudMart Terraform Deployment Guide

This guide details how to provision and manage the AWS infrastructure for the CloudMart platform using its restructured Terraform layout.

---

## 📁 Directory Structure

```
infra/
├── bootstrap/          # One-time setup: remote state S3 bucket & DynamoDB lock table
├── environments/
│   ├── prod/           # Production environment (calls root modules via source = "../../")
│   └── staging/        # Staging environment (calls individual modules directly)
├── modules/            # Reusable Terraform modules
│   ├── budget/
│   ├── disaster-recovery/
│   ├── dynamodb/
│   ├── ecr/
│   ├── eks/
│   ├── guardduty/
│   ├── iam/
│   ├── kms/
│   ├── monitoring/
│   ├── rds/
│   ├── route53/
│   ├── s3/
│   ├── secrets-manager/
│   ├── security/
│   ├── ses/
│   ├── sqs/
│   ├── vpc/
│   └── waf/
└── main.tf             # Root module: composes core infrastructure modules
```

---

## 🛠️ Step 0: Bootstrap Remote State

The `infra/bootstrap/` directory uses a **local state backend** and is only run once. It provisions the S3 bucket and DynamoDB table used by all other environment backends.

**Outputs:**
- S3 bucket: `cloudmart-tfstate-<team>` (versioned, AES256-encrypted, public access blocked)
- DynamoDB table: `cloudmart-tfstate-lock` (for state locking)

```bash
# Navigate to the bootstrap directory
cd infra/bootstrap

# Initialize Terraform (uses local state)
terraform init

# Apply to create the remote state bucket and locking table
terraform apply -auto-approve
```

> [!IMPORTANT]
> Run this step **only once** per team/account. The bucket name is derived from the `project` and `team` variables (defaults: `cloudmart` and `team_axel`).

---

## 🚀 Step 1: Deploy Production Environment

The `infra/environments/prod/` directory targets the production AWS account. It calls the root `infra/main.tf` module (via `source = "../../"`), which in turn composes all core infrastructure modules:

**Modules provisioned via `infra/main.tf`:**
| Module | What it provisions |
|---|---|
| `vpc` | VPC, subnets, NAT gateways, bastion host |
| `kms` | KMS key for encryption across services |
| `ses` | SES email identity for notifications |
| `eks` | EKS cluster, node groups (EC2 or Fargate) |
| `waf` | AWS WAF WebACL (optional) |
| `route53` | Hosted zone for the domain |
| `budget` | AWS Budget alert with email notifications |
| `security` | Security Hub & GuardDuty (optional) |
| `disaster_recovery` | Cross-region backup & recovery setup |

**Remote state backend:** `s3://cloudmart-tfstate-team_axel` → key `environments/prod/terraform.tfstate`

```bash
# Navigate to the production environment directory
cd infra/environments/prod

# Initialize Terraform with the S3 remote backend
terraform init

# Preview planned changes
terraform plan -out=prod.tfplan

# Apply the approved changes
terraform apply prod.tfplan
```

---

## 🧪 Step 2: Deploy Staging Environment

The `infra/environments/staging/` directory provisions a **lightweight staging stack** by calling individual modules directly with a `staging` environment tag and a dedicated AWS provider alias.

**Modules provisioned in staging:**
| Module | What it provisions |
|---|---|
| `secrets_manager_staging` | Secrets Manager secret for DB credentials & JWT |
| `s3_staging` | S3 bucket for staging assets (KMS-encrypted) |
| `dynamodb_staging` | DynamoDB tables for staging workloads |
| `ecr_staging` | ECR repositories for staging container images |
| `sqs_staging` | SQS queues for staging message processing |
| `rds_staging` | RDS PostgreSQL instance in private subnets |
| `iam_staging` | IRSA roles scoped to `cloudmart-staging` namespace |
| `monitoring_staging` | CloudWatch alarms & SNS alerts for staging |

```bash
# Navigate to the staging environment directory
cd infra/environments/staging

# Initialize Terraform
terraform init

# Preview planned changes
terraform plan -out=staging.tfplan

# Apply the approved changes
terraform apply staging.tfplan
```

> [!IMPORTANT]
> Staging depends on the VPC, EKS cluster, and KMS key provisioned by the **prod** environment. Ensure Step 1 is fully applied before deploying staging.

---

## 🔑 Key Variables (Prod Environment)

| Variable | Default | Description |
|---|---|---|
| `project` | `cloudmart` | Project name prefix for all resources |
| `environment` | `prod` | Deployment environment tag |
| `team` | `team_axel` | Team name (used for unique S3 bucket naming) |
| `region` | `ap-south-1` | AWS region |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `single_nat_gateway` | `false` | Use a single NAT gateway (cost saving for non-prod) |
| `kubernetes_version` | `1.27` | EKS Kubernetes version |
| `node_instance_type` | `t3.medium` | EC2 worker node instance type |
| `desired_node_count` | `2` | Number of EKS worker nodes |
| `use_fargate` | `false` | Use Fargate instead of EC2 nodes |
| `enable_waf` | `false` | Enable AWS WAF |
| `enable_guardduty` | `false` | Enable GuardDuty threat detection |
| `domain_name` | `example.com` | Route53 root domain |
| `limit_amount` | `1000` | AWS Budget monthly limit (USD) |
| `subscriber_emails` | `[]` | Email list for budget/monitoring alerts |
| `from_email` | `no-reply@cloudmart.com` | SES sender email address |

---

## ♻️ Destroy Infrastructure

```bash
# Destroy staging first (it depends on prod resources)
cd infra/environments/staging
terraform destroy

# Then destroy production
cd infra/environments/prod
terraform destroy

# Finally, destroy the bootstrap resources (only when fully decommissioning)
cd infra/bootstrap
terraform destroy
```

> [!CAUTION]
> Destroying the bootstrap stack will delete the remote state S3 bucket and DynamoDB lock table. Do this **only** when fully decommissioning the project.