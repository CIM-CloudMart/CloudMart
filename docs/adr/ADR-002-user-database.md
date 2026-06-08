# ⚖️ ADR-002: User Service Database Selection

* **Status:** ![Status: Accepted](https://img.shields.io/badge/Status-Accepted-success?style=flat-square)
* **Date:** 2026-06-08
* **Deciders:** CloudMart Platform Engineering Team

---

## 📝 1. Context

The **user-service** requires persistent storage for core user schemas including authentication credentials, user profiles, session tokens, and access roles. 

The database solution must:
1. Provide ACID compliance and relational integrity.
2. Support secure communication and encrypt data at rest.
3. Require minimal administrative overhead for patching, scaling, and backups.
4. Integrate cleanly with EKS workloads.

---

## 🚀 2. Decision

We chose **Amazon RDS PostgreSQL** as the database engine for the `user-service`.

> [!NOTE]
> **Active Terraform Specifications:**
> * **Instance Class:** Configurable via variables, defaulting to `db.t3.micro` for staging and low-traffic environments.
> * **Network Isolation:** Placed in private data subnets (`private_data_subnet_ids`), restricting access to the EKS cluster security group.
> * **Storage Resiliency:** Automated storage scaling enabled up to `max_allocated_storage = 20` GB, alongside KMS storage encryption (`storage_encrypted = true`).
> * **Production Safety:** Production deployments enable `deletion_protection = true` and configure a final snapshot capture.

---

## 📈 3. Consequences

### Positive (Advantages)
* **Managed Overhead:** AWS handles hardware provisioning, OS patching, and engine updates.
* **Continuous Backups:** Built-in automated snapshots (configured in daily windows) allow point-in-time recovery.
* **Availability Upgrades:** Multi-AZ (`multi_az`) configurations can be enabled via simple Terraform parameters, creating a synchronous backup instance in a secondary AZ.
* **Robust Ecosystem:** PostgreSQL provides native indexing, JSONB support, and strong relational constraint checks.

### Negative (Disadvantages)
* **Base Cost:** Running RDS PostgreSQL instances is more expensive (~$15.44/mo base) compared to hosting databases inside Kubernetes.
* **Network Latency:** Traffic crosses network boundaries between EKS worker nodes and RDS subnets, requiring proper security group configuration.

---

## 🔍 4. Alternatives Considered

| Option | Pros | Cons | Assessment |
| :--- | :--- | :--- | :--- |
| **Self-Hosted PostgreSQL (on K8s)** | Zero AWS service fees; unified K8s control. | Requires manual replication, backups, storage management, and patching. | **Rejected.** The operational overhead for stateful pods is too high. |
| **Amazon DynamoDB** | High write scaling; serverless pricing; simple API. | Poor relational query support; indexing limits; schema rigidity. | **Rejected.** Relational schema integrity is preferred for user identity profiles. |
| **Amazon RDS MySQL** | Strong relational database; managed service. | MySQL lacks advanced PostgreSQL types (such as natively optimized JSONB data). | **Rejected.** PostgreSQL offers superior relational performance and extensions. |