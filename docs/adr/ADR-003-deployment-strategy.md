# ⚖️ ADR-003: Kubernetes Deployment Strategy

* **Status:** ![Status: Accepted](https://img.shields.io/badge/Status-Accepted-success?style=flat-square)
* **Date:** 2026-06-08
* **Deciders:** CloudMart Platform Engineering Team

---

## 📝 1. Context

CloudMart requires a highly available deployment pipeline capable of updating backend microservices with zero application downtime. To support rapid iterative releases, updates must:
1. Prevent request timeouts or drops during container upgrades.
2. Enable automatic rollbacks if new pods fail startup checks.
3. Be compatible with the AWS Application Load Balancer (ALB) controller.

---

## 🚀 2. Decision

We selected the **Kubernetes `RollingUpdate` deployment strategy** for all stateless microservices.

> [!NOTE]
> **ALB Ingress Controller Integration:**
> * **AWS EKS Fargate:** The ALB Ingress controller routing annotations use `alb.ingress.kubernetes.io/target-type: ip`. Under Fargate, traffic is routed directly to the pod IP addresses.
> * **AWS EKS EC2 Node Groups:** If migrated to EC2 worker nodes, target-type can remain `ip` (using VPC CNI secondary IP mode) or switch to `instance` mode, routing traffic to dynamic NodePorts on EC2 instances.

---

## 📈 3. Consequences

### Positive (Advantages)
* **Zero Downtime:** New containers spin up and pass readiness checks before old containers are terminated.
* **Safer Release Verification:** Active traffic is routed only to active, healthy pods.
* **Dynamic Scaling Compatibility:** Seamlessly integrates with Kubernetes Horizontal Pod Autoscaler (HPA).

### Negative (Disadvantages)
* **Incremental Release Speed:** Deployments are slower than simple "Recreate" operations, as containers must launch sequentially.
* **Version Coexistence:** During rolling deployments, two versions of the microservice run simultaneously. APIs must maintain backward compatibility.

---

## 🔍 4. Alternatives Considered

| Deployment Strategy | Pros | Cons | Assessment |
| :--- | :--- | :--- | :--- |
| **`Recreate`** | Simple; no concurrent version conflicts. | Complete service downtime during container replacements. | **Rejected.** Unacceptable for production/staging environments. |
| **`Blue/Green`** | Instant cutover; simple rollback. | Requires doubling cluster compute resources during releases. | **Rejected.** Too expensive for staging sandbox resources. |
| **`Canary`** | Safest traffic testing; gradual rollout. | Requires complex mesh setups (such as Istio/Linkerd) or advanced ingress configurations. | **Deferred.** Best reserved for future production scaling phases. |
| **`RollingUpdate`** | Free; built-in; zero downtime. | Version coexistence (requires database schema backward compatibility). | **Accepted.** Delivers maximum uptime with minimal design complexity. |