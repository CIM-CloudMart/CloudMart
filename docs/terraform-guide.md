# Run the terraform commands in the order below

> **Free tier / vCPU quota:** Clusters use **EKS Fargate** (`use_fargate = true`) so pods run at **0.25 vCPU** each instead of EC2 nodes (2 vCPU minimum). Set pod `resources.requests` to `cpu: 250m` and `memory: 512Mi` in Kubernetes manifests. GuardDuty is off by default on free-tier accounts. RDS backup retention is **1 day** (free-tier max).
>
> **EKS version:** Prod stays on **1.30** (existing cluster). AWS only allows **one minor version** upgrade at a time (1.30 → 1.31 → …). Staging uses **1.33** (created fresh).

## Staging
```bash
cd infra/environments/staging
```
```bash
terraform init -reconfigure
```
```bash
terraform plan -out=tfplan
```
```bash
terraform apply tfplan
```

## Production
```bash
cd ../prod
```
```bash
terraform init -reconfigure
```
```bash
terraform plan -out=tfplan
```
```bash
terraform apply tfplan
```