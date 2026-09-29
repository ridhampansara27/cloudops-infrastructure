# CloudOps Insight infrastructure

Terraform for the OCI platform hosting [CloudOps Insight](https://github.com/ridhampansara27/cloudops-insight). The application is deployed separately through [cloudops-gitops](https://github.com/ridhampansara27/cloudops-gitops) and Argo CD. Former AWS EKS hosting has been retired; AWS remains an external monitored customer cloud.

> **Certified commercial-launch infrastructure snapshot (29 September 2026):** repository `main` at `54ddda1611a036a60250fa8e49ab3f1bd36b468d`. Verify current Terraform state and OCI resources before any plan or recovery operation.

## Current OCI topology

```mermaid
flowchart TB
    USERS["Users"] --> CF["Cloudflare edge"]
    CF --> TUNNEL["Outbound Cloudflare Tunnel"]
    subgraph VCN["OCI Frankfurt · VCN"]
      API["Public OKE API · restricted CIDR / NSG"]
      subgraph WORKER["OKE Basic · 1 ARM A1 worker"]
        TUNNEL --> FE["Frontend / NGINX"]
        FE --> BACK["FastAPI · Celery"]
        BACK --> PG[("PostgreSQL PVC · OCI Block Volume")]
        BACK --> REDIS[("Redis · ephemeral")]
      end
    end
    PG --> VOL[("OCI volume backup policy")]
    PG --> OBJ[("Logical dumps · private Object Storage")]
    STATE[("Separate Object Storage Terraform state")] --> TF["Authenticated operator Terraform"]
    TF --> VCN
    classDef edge fill:#dbeafe,stroke:#2563eb,color:#172554;
    classDef compute fill:#ede9fe,stroke:#7c3aed,color:#2e1065;
    classDef data fill:#dcfce7,stroke:#16a34a,color:#14532d;
    class USERS,CF,TUNNEL,API edge;
    class FE,BACK,TF compute;
    class PG,REDIS,VOL,OBJ,STATE data;
```

The API endpoint is public but restricted by its NSG and configured administrator CIDR. The worker subnet permits public IPs for low-cost outbound access, with no Internet-facing application ports in its NSG. Application traffic enters through Cloudflare Tunnel, not an OCI Load Balancer. This single-worker, in-cluster PostgreSQL design is **not highly available**.

## Repository map

| Path | Status and ownership |
|---|---|
| `environments/oci-dev/` | **Active** OCI compartment, VCN, OKE, backups, bucket/lifecycle policy, Sealed Secrets recovery vault, remote state |
| `modules/oci-network/`, `modules/oke/` | Reusable OCI VCN/security and OKE components |
| `bootstrap/` | Historical AWS state and GitHub OIDC bootstrap configuration; inspect before any use |
| `environments/dev/` | Retired EKS environment tombstone, retained for state-history safety |
| `modules/eks/`, `modules/network/`, `modules/rds/`, `modules/iam/`, `modules/secrets/` | Historical AWS architecture modules, not referenced by active OCI environment |
| `docs/history/` | Preserved AWS cost, services, networking, and demo notes |

The label `oci-dev` is historical: it is the currently used OCI commercial host. See [architecture](docs/architecture.md) for current and historical boundaries.

## Versions and sizing represented by code

| Component | Configured value | Source |
|---|---|---|
| Terraform CLI | `>= 1.11.0` required; CI uses `1.15.8` | OCI `versions.tf`, PR workflow |
| Oracle OCI provider | `8.29.0` locked | OCI `.terraform.lock.hcl` |
| OKE Kubernetes | `v1.35.2` **variable default**, not live verification | OCI `variables.tf` |
| Cluster and networking | Basic tier, Flannel Overlay | `modules/oke/main.tf` |
| Worker | 1 × `VM.Standard.A1.Flex`, 2 OCPUs, 12 GB RAM, 50 GB boot volume | OCI `main.tf` |
| AWS bootstrap providers | `6.60.0` and `6.62.0` locks | Two historical bootstrap lockfiles |

Kubernetes and node-image versions must be verified against the running OCI cluster. PostgreSQL `17-alpine` and application image tags live in GitOps rather than Terraform.

## Terraform state and change process

OCI state is stored in a separately provisioned private Object Storage bucket; the state bucket is **not** managed by the state it holds. Local `terraform.tfvars` and OCI CLI API-key profile are ignored by Git. Never commit state, plans, API keys, bucket credentials, or a real administrator CIDR.

Pull-request CI runs formatting, backend-disabled OCI validation, Trivy IaC scanning, and a credential-free **retired AWS tombstone no-op plan**. Its required check named “Terraform plan” is **not** an OCI cloud-connected plan. An authenticated operator currently reviews and applies OCI changes manually.

Read [the OCI change runbook](docs/runbooks/oci-change.md) before planning or applying. The following commands are **local static validation only**:

```powershell
Set-Location environments/oci-dev
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

`terraform init -backend=false` does not check remote state or current OCI drift. A cloud-connected plan requires the authorized OCI profile, state access, and an operator review.

## Backups and disaster recovery

Terraform assigns the PostgreSQL Block Volume daily incremental backups (7-day retention) and weekly incremental backups (28-day retention). It also manages a private logical-backup bucket with a 30-day object lifecycle, lifecycle service IAM, and protected OCI Vault/key resources for Sealed Secrets recovery. The GitOps CronJob produces and uploads the **logical** dumps; Terraform does not execute that Job.

Use [the backup and state recovery runbook](docs/runbooks/oci-recovery.md). The certified launch included an isolated database restore drill, but each subsequent backup still needs independent monitoring and periodic restore testing.

## Security and contribution

The active VCN uses network security groups to restrict the public Kubernetes API to an explicit administrator CIDR. Cloudflare Tunnel supplies public application access without an OCI application Load Balancer. OCI Kubernetes uses Flannel Overlay; do not claim Kubernetes NetworkPolicy enforcement until the networking implementation changes.

See [SECURITY.md](SECURITY.md), [CONTRIBUTING.md](CONTRIBUTING.md), and [CHANGELOG.md](CHANGELOG.md). No documentation change in this repository requires or performs a Terraform apply.
