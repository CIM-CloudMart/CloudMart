# 🛡️ CloudMart Disaster Recovery Plan

This document outlines the Disaster Recovery (DR) strategies, technical capabilities, and emergency response plans designed to guarantee business continuity and minimize data loss for the **CloudMart** microservices platform.

---

## 🎯 1. Recovery Objectives

Our recovery plans target two primary metrics:
* **Recovery Time Objective (RTO):** The maximum tolerable downtime for services before recovery.
* **Recovery Point Objective (RPO):** The maximum tolerable age of data that can be lost due to an incident.

| Metric | Target | Scope | Notes |
| :--- | :--- | :--- | :--- |
| **RTO (Service Recovery)** | **5 – 15 Minutes** | Standard Component Failures | Covers pod, node, or database instance failures. |
| **RTO (Region Disaster)** | **2 – 4 Hours** | Complete AWS Region Outage | Involves redeploying infrastructure to a backup region via IaC. |
| **RPO (Relational Data)** | **Near-Zero (Multi-AZ)** | Database Failures | RDS PostgreSQL synchronous replication keeps standby instances updated. |
| **RPO (Relational Backup)** | **Max 24 Hours** | Severe DB Corruption | Restored from the latest automated database snapshots. |
| **RPO (NoSQL Data)** | **Point-in-Time (PITR)** | DynamoDB Deletions | Restorable to any second in the past 35 days (production only). |
| **RPO (Asset Storage)** | **Zero Data Loss** | S3 Object Deletions | Enabled S3 Object Versioning safeguards all binary assets. |

---

## 🏗️ 2. Architectural Resilience & Automated Self-Healing

The CloudMart infrastructure is provisioned using Terraform to leverage native AWS and Kubernetes high-availability mechanisms.

```mermaid
graph TD
    A["🚨 Incident / Outage Detected"] --> B{"What failed?"}
    
    B -->|Pod Crash| C["K8s Liveness Probe Fails"]
    C --> D["Kubelet terminates and recreates Container"]
    D --> H["🟢 Service Restored"]
    
    B -->|Node Outage| E["EKS Node marked NotReady"]
    E --> F["Pods rescheduled onto healthy worker nodes / Fargate"]
    F --> H
    
    B -->|Database Failure| G["RDS PostgreSQL Primary Instance Fails"]
    G --> I["Synchronous standby promoted to Primary"]
    I --> J["DNS Record updated to point to new standby"]
    J --> K["Microservices auto-reconnect to RDS Endpoint"]
    K --> H
```

### ☸️ Kubernetes Self-Healing & Deployment Policies
* **Liveness & Readiness Probes:** Kubernetes continuously checks pod health. Unhealthy pods are terminated and restarted automatically.
* **Rolling Updates:** Zero-downtime updates are enforced via the `RollingUpdate` strategy, maintaining service availability by rotating pods incrementally.
* **Replication & Pod Anti-Affinity:** Microservices run with multiple replicas across different Availability Zones to prevent single-point-of-failure (SPOF) disruptions.

### 💾 AWS Data Layer Resiliency
The database tier uses managed AWS services configured with robust durability rules:

* **RDS PostgreSQL (`db.t3.micro`):**
  * **Multi-AZ Availability:** Can be provisioned with a synchronous standby instance in a different Availability Zone (`rds_multi_az = true` in Terraform) for instant failover.
  * **Automated Storage Autoscaling:** The database scales its allocation dynamically up to a configured threshold (`max_allocated_storage = 20` GB) to prevent out-of-disk write failures.
  * **Deletion Protection:** Enabled in production (`deletion_protection = true`) to prevent accidental resource destruction via Terraform or AWS CLI.
  * **Automated Backups:** Daily snapshots are captured in a daily window (`03:00 - 04:00 AM`) and retained, with a final snapshot enforced before any voluntary deletion.
* **DynamoDB Product Table:**
  * **Point-in-Time Recovery (PITR):** Active in production (`point_in_time_recovery { enabled = true }`), allowing operations to roll back the database state to any specific second in the preceding 35 days.
* **Amazon S3 Asset Storage:**
  * **Object Versioning:** Versioning is enabled (`status = "Enabled"`), ensuring that file overwrites or deletions create a new version of the object instead of erasing it.
  * **Encrypted Backups:** Bounded by KMS Customer Managed Keys (`aws:kms` server-side encryption) to prevent raw data exposure during recovery actions.
* **SQS Message Queue Durability (`order_events`):**
  * **Message Durability:** Order events are kept in the queue for up to 14 days, protecting data from backend processing drops.
  * **Dead Letter Queue (DLQ):** Failed messages are routed to `order_events_dlq` after a specific count of failed processing attempts (`maxReceiveCount`), preventing poison messages from halting processing while saving transaction attempts.

---

## 📋 3. Failure Scenarios & Mitigation Procedures

> [!IMPORTANT]
> In any critical event, verify service status using AWS CloudWatch monitoring dashboards and Kubernetes status commands (`kubectl get pods -n production`).

### Scenario A: Application Pod or Container Failure
1. **Detection:** Kubernetes liveness probes fail; CloudWatch monitors show HTTP 5xx spikes.
2. **Auto-Mitigation:** Kubernetes terminates the pod and starts a new instance.
3. **Manual Verification:** 
   ```bash
   kubectl get pods -n production
   kubectl logs -n production deployment/<service-name> --tail=50
   ```

### Scenario B: EKS Worker Node or Fargate VM Outage
1. **Detection:** Pods show `Pending` or nodes status shows `NotReady`.
2. **Auto-Mitigation:** For Fargate deployments, AWS automatically provisions fresh container capacity. For EC2 Node Groups, EKS reschedules pods to alternative nodes in active AZs, and Cluster Autoscaler handles VM provisioning.
3. **Manual Verification:**
   ```bash
   kubectl get nodes -o wide
   kubectl get pods -n production -o wide
   ```

### Scenario C: PostgreSQL Database Primary Outage
1. **Detection:** Backend logs show database connection timeouts; RDS status shifts to `failing-over`.
2. **Auto-Mitigation:** AWS RDS automatically updates Route 53 CNAME routing to point to the Multi-AZ standby replica.
3. **Manual Verification:** Verify connectivity via the backend microservices.
   ```bash
   kubectl exec -it -n production deploy/user-service -- pg_isready -h <rds-endpoint> -p 5432
   ```

### Scenario D: Human Error / Accidental Deletions (Database or Files)
1. **Data Corruption:** Use AWS RDS Console to restore the database from a backup snapshot to a specific timestamp, or use DynamoDB PITR console.
2. **Accidental File Erasure:** Access the S3 storage bucket, locate the deleted object, and restore its previous version from the versioning tab.

---

## 🗺️ 4. Disaster Recovery Configuration Reference

> [!TIP]
> Ensure AWS Budgets are set up (`limit_amount = "100"`) to monitor unexpected cost spikes during disaster recovery exercises.

The parameters enforcing recovery features are located inside the Infrastructure-as-Code files:
* **RDS Config:** `CloudMart/infra/modules/rds/main.tf`
* **DynamoDB Config:** `CloudMart/infra/modules/dynamodb/main.tf`
* **S3 Versioning Config:** `CloudMart/infra/modules/s3/main.tf`
* **SQS DLQ Config:** `CloudMart/infra/modules/sqs/main.tf`