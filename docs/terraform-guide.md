# CloudMart Infrastructure Deployment Guide (Terraform)

This guide details instructions to provision the AWS infrastructure supporting the CloudMart platform.

> **Free Tier / Cost Management Notice:**
> - AWS EKS Fargate (`use_fargate = true`) runs pod nodes at **0.25 vCPU** and **512Mi Memory** to avoid standard EC2 Standard vCPU quota issues.
> - **Security Features Active by Default**: AWS GuardDuty and AWS Security Hub are now enabled in environments `terraform.tfvars` (`enable_guardduty = true`). WAF is configurable via `enable_waf` (WAF regional ACL is not free-tier eligible).
> - EKS Access Entries are automatically provisioned to authenticate the assumed GitHub Actions IAM Role and local developer roles.

---

## 1. Staging Environment
Provision the staging AWS environment:

```bash
cd infra/environments/staging
terraform init -reconfigure
terraform plan -out=tfplan
terraform apply tfplan
```

### Key Outputs to Record
- `web_acl_arn`: The ARN of the regional WAF ACL (configure in Helm values if WAF is enabled).
- `github_actions_role_arn`: Assumed role for the CI/CD pipeline.
- `eks_cluster_name`: `cloudmart-eks-staging`
- `rds_endpoint`: PostgreSQL endpoint.

---

## 2. Production Environment
Provision the production AWS environment:

```bash
cd ../prod
terraform init -reconfigure
terraform plan -out=tfplan
terraform apply tfplan
```

### Key Outputs to Record
- `web_acl_arn`: The WAF ACL ARN for edge filtering.
- `github_actions_role_arn`: Assumed OIDC role for production CD.
- `eks_cluster_name`: `cloudmart-eks-prod`
- `rds_endpoint`: Production database endpoint.