# ⚖️ ADR-001: Kubernetes Node Instance Type Selection

* **Status:** ![Status: Accepted](https://img.shields.io/badge/Status-Accepted-success?style=flat-square)
* **Date:** 2026-06-08
* **Deciders:** CloudMart Platform Engineering Team

---

## 📝 1. Context

The CloudMart platform hosts five distinct microservices (frontend, user, product, order, notification) alongside Kubernetes core system controllers, ingress traffic routers, autoscalers, and Prometheus/fluent-bit observability agents. 

During the initial testing phase, deploying these workloads onto `t3.micro` instances resulted in scheduling failures, CPU throttling, and out-of-memory (OOM) pod evictions due to strict resource constraints. The team required a cost-efficient compute tier that could reliably handle the multi-container platform lifecycle.

---

## 🚀 2. Decision

We chose **`t3.medium` instances** (2 vCPUs, 4 GiB Memory) as the baseline worker node type for EKS Managed Node Groups.

> [!NOTE]
> **EKS Fargate Compatibility:** 
> To mitigate AWS EC2 Standard vCPU quota restrictions on developer sandbox accounts, the current Terraform infrastructure defaults to EKS Fargate serverless profiles (`use_fargate = true` in `terraform.tfvars`). Fargate runs pods inside micro-VMs using a customized `0.25 vCPU / 512 MiB` footprint. 
> 
> However, for dedicated VM compute setups, the Terraform variables are pre-configured to provision EKS Managed Node Groups containing `t3.medium` instances as soon as `use_fargate` is set to `false`.

---

## 📈 3. Consequences

### Positive (Advantages)
* **Resource Abundance:** Provides ample CPU and memory overhead to prevent container resource starvation and support scale-up tests.
* **Operational Stability:** Drastically reduces OOM pod crashes and system node instability compared to smaller EC2 classes.
* **Auto-Scaling Tests:** Provides enough space on each node to host replica scaling and HPA (Horizontal Pod Autoscaler) tasks.

### Negative (Disadvantages)
* **Higher Compute Costs:** Moving from `t3.micro` to `t3.medium` increases the EC2 billing rate from ~$7.50/mo to ~$30.37/mo per node.
* **Resource Isolation Limits:** Unlike Fargate, multiple microservices share VM kernel capacity; a single unstable pod could theoretically impact neighboring pods without proper resource bounds configured.

---

## 🔍 4. Alternatives Considered

| Instance Type | Specs (vCPU / RAM) | Assessment |
| :--- | :--- | :--- |
| **`t3.micro`** | 1 vCPU / 1 GiB | **Rejected.** Insufficient allocatable memory for basic EKS system pods and application workloads. |
| **`t3.small`** | 2 vCPUs / 2 GiB | **Rejected.** Marginal memory capacity; leaves no room for scaling replicas or resource-intensive logging agents. |
| **`t3.medium`** | 2 vCPUs / 4 GiB | **Accepted.** Delivers the optimal cost-to-performance balance for stable cluster operations. |

---

## 🔍 5. Compute Sizing Recommendations Review

Under production and staging workloads, we evaluated AWS Compute Optimizer recommendations to optimize cluster cost-efficiency:

1. **Staging Environment Recommendation (Downsize to `t3.small` / Limit Fargate)**:
   * *Recommendation:* AWS Compute Optimizer identifies staging instances as underutilized and recommends downsizing worker nodes to `t3.small` (saves ~$15/mo) or restricting Fargate resources.
   * *Decision:* **Rejected.**
   * *Justification:* During CI/CD rolling deployments, system overhead spikes significantly. Downsizing below `t3.medium` or restricting memory constraints causes scheduling failures, deployment timeouts, and Out-of-Memory (OOM) pod crashes. Maintaining a stable compute floor is critical to avoid development bottlenecks.
2. **Production Environment Recommendation (Maintain `t3.medium` / Fargate base)**:
   * *Recommendation:* Retain compute capacity at `t3.medium` or equivalent Fargate compute allocation profiles (`0.25 vCPU / 512 MiB` per microservice pod).
   * *Decision:* **Accepted.**
   * *Justification:* Current allocations are optimal due to overhead from system controllers, ingress traffic routers, and sidecar agents (AWS VPC CNI, CoreDNS, and CloudWatch Fluent Bit logging containers).