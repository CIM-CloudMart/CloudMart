# CloudMart Terraform Deployment Guide for Fresh AWS Accounts

This guide details the procedures, requirements, and best practices for deploying the CloudMart infrastructure to a brand new or completely empty AWS account.

---

## 📋 Prerequisites

Before initiating the deployment, ensure you have the following installed and configured:

1. **AWS CLI** (v2.x) - Configured with administrative access to your new AWS account.
2. **Terraform** (v1.8+) - Verified with `terraform -v`.
3. **IAM User / Assumed Role** - The entity executing the deployment must have administrative credentials.

---

## 🛠️ Step 0: Bootstrap remote state

To prevent local state storage conflicts, CloudMart uses S3 to store remote state files and DynamoDB for state locking. Since S3 bucket names must be globally unique, you must follow the bootstrap flow:

### 1. Initialize the Bootstrap Stack
Navigate to the bootstrap directory and initialize Terraform (it uses local state backend):

```bash
cd infra/bootstrap
terraform init
```

### 2. Configure Your Team Identifier
In `infra/bootstrap/variables.tf`, specify a unique team identifier. Alternatively, pass it as a variable during apply:

```bash
terraform apply -var="team=my-unique-team-identifier" -auto-approve
```

**Created Resources:**
- S3 Bucket: `cloudmart-tfstate-<team>` (e.g., `cloudmart-tfstate-my-unique-team-identifier`)
- DynamoDB Lock Table: `cloudmart-tfstate-lock`

### 3. Update the Backend Configurations
After the bootstrap completes, copy the created S3 bucket name and update the backend configurations in:
- `infra/environments/prod/backend.tf`
- `infra/environments/staging/backend.tf`

Example update in `backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "cloudmart-tfstate-my-unique-team-identifier"
    key            = "environments/prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "cloudmart-tfstate-lock"
    encrypt        = true
  }
}
```

---

## 🔑 IAM Role Creation & EKS Access Entry Flow

In EKS, access entries allow external IAM roles and users to be granted RBAC permissions within Kubernetes. When deploying to a brand new AWS account, EKS access entries have specific lifecycle constraints:

### 1. EKS Validation Prerequisite
AWS EKS validates that the IAM principal ARN actually exists before registering it as an EKS access entry. If the role does not exist in IAM, AWS EKS returns:
`InvalidParameterException: The specified principalArn is invalid: invalid principal.`

### 2. Decoupled Lifecycle Design
Because of this validation, CloudMart decouples role registration by environment:
- **Production Workspace (`prod`)**: Creates the production GitHub Actions OIDC role (`cloudmart-github-actions-role-prod`) and automatically registers its EKS access entry within the same plan since they are created together.
- **Staging Workspace (`staging`)**: Staging resources (including the staging GitHub Actions role `cloudmart-github-actions-role-staging`) are deployed after production. The EKS access entry for the staging role is declared inside the staging workspace so it is only registered once the staging role itself exists.
- **CI/CD Role**: If you use an external CI/CD role (e.g., `ci-cd`), you can provide its ARN via the `cicd_role_arn` variable. It will only be registered if the variable is set, preventing errors when deploying to a fresh account where the role does not exist.

---

## 🪣 S3 Bucket Naming Strategy

To avoid global name collisions (`BucketAlreadyExists: The requested bucket name is not available`), S3 bucket names in CloudMart use a deterministic naming strategy combining:
- Project Name (e.g., `cloudmart`)
- Environment (e.g., `prod` / `staging`)
- Team Name / Bucket Type
- AWS Account ID
- AWS Region

### Example S3 Buckets:
- Static Error Page: `cloudmart-prod-error-page-<account_id>-<region>`
- App Storage: `cloudmart-storage-<team>-prod-<account_id>-<region>`
- Maintenance Failover: `failover-cloudmart-prod-<team>-<account_id>-<region>`

---

## 🚀 Execution Steps (Full Flow)

### 1. Production Deployment
```bash
cd infra/environments/prod
terraform init
terraform plan -out=prod.tfplan
terraform apply prod.tfplan
```

### 2. Staging Deployment
```bash
cd infra/environments/staging
terraform init
terraform plan -out=staging.tfplan
terraform apply staging.tfplan
```

---

## 🔍 Troubleshooting Guide & Common Failures

### 1. `InvalidParameterException` on EKS Access Entry
- **Issue:** EKS states that `principalArn` is invalid.
- **Resolution:** Verify if you are using STS assumed role credentials to run the plan. The EKS module converts `arn:aws:sts::...` to `arn:aws:iam::...:role/...` automatically, but if you have a custom structure, pass your IAM role ARN directly using `-var="admin_principal_arn=arn:aws:iam::<account_id>:role/<role_name>"`.
- **Resolution 2:** Ensure you are not attempting to deploy `staging` access entries before deploying staging. Keep staging access entries inside the staging workspace.

### 2. `BucketAlreadyExists` on S3 Bucket
- **Issue:** Another AWS user has taken the bucket name.
- **Resolution:** Change your `team` variable in `variables.tf` or ensure your current AWS caller identity has a valid account ID. The default suffix `${data.aws_caller_identity.current.account_id}` guarantees global uniqueness in your AWS account.

### 3. `ResourceNotFoundException: The specified principalArn could not be found.`
- **Issue:** Occurs on `aws_eks_access_policy_association` when IAM role creation has not fully propagated in AWS before EKS checks it.
- **Resolution:** The code now has explicit `depends_on = [module.iam]` settings. If you still encounter this, rerun `terraform apply` after a few seconds.
