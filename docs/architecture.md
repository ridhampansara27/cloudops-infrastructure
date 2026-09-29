# OCI infrastructure architecture

## Active control and data planes

```mermaid
flowchart TB
    OP["Operator · OCI CLI API-key profile"] --> TF["Terraform · remote state"]
    TF --> COMP["CloudOps compartment"]
    COMP --> VCN["VCN · Internet Gateway · route table"]
    VCN --> APISUB["OKE API subnet · public endpoint · CIDR/NSG restricted"]
    VCN --> NODESUB["Worker subnet · NSG · no public application ingress"]
    APISUB --> OKE["OKE Basic control plane"]
    NODESUB --> POOL["A1 Flex · 1 ARM worker"]
    OKE --> POOL
    POOL --> BV[("PostgreSQL Block Volume")]
    BV --> POLICY[("Daily/weekly volume backup policy")]
    POOL --> DUMP["GitOps PostgreSQL dump Job"]
    DUMP --> BUCKET[("Private Object Storage backup bucket")]
    TF --> VAULT[("Sealed Secrets recovery Vault/key")]
    classDef operator fill:#dbeafe,stroke:#2563eb,color:#172554;
    classDef network fill:#ede9fe,stroke:#7c3aed,color:#2e1065;
    classDef compute fill:#fef3c7,stroke:#d97706,color:#78350f;
    classDef data fill:#dcfce7,stroke:#16a34a,color:#14532d;
    class OP,TF operator;
    class COMP,VCN,APISUB,NODESUB network;
    class OKE,POOL,DUMP compute;
    class BV,POLICY,BUCKET,VAULT data;
```

The separately bootstrapped Object Storage Terraform backend is not represented by the backup bucket above. The two buckets serve different recovery purposes. Terraform manages cloud resources; [GitOps](https://github.com/ridhampansara27/cloudops-gitops) manages Kubernetes workloads and the logical dump CronJob.

## Public application route

```mermaid
flowchart LR
    USER["Browser"] --> EDGE["Cloudflare"]
    EDGE --> TUNNEL["Outbound Tunnel from OKE"]
    TUNNEL --> FE["Frontend ClusterIP / NGINX"]
    FE --> API["Backend ClusterIP / FastAPI"]
    API --> DB[("PostgreSQL")]
    classDef public fill:#dbeafe,stroke:#2563eb,color:#172554;
    classDef compute fill:#ede9fe,stroke:#7c3aed,color:#2e1065;
    classDef data fill:#dcfce7,stroke:#16a34a,color:#14532d;
    class USER,EDGE,TUNNEL public;
    class FE,API compute;
    class DB data;
```

The public Kubernetes API endpoint is an **operator control-plane path**, separate from the browser route. OCI NSG ingress restricts access to the configured administrator CIDR. The application uses no OCI public Load Balancer or public NodePort.

## Former AWS EKS host

`environments/dev/` is an inert state-history tombstone. EKS, ALB, VPC, IAM, RDS, and secret modules remain as historical architecture material. They are not called from active `environments/oci-dev/main.tf`. AWS customer accounts are still monitored by the OCI-hosted application through STS cross-account roles; this does not recreate EKS hosting. The preserved EKS cost and demo documents live in [history](history/).

## Recovery dependencies

- Remote OCI Terraform state and its bucket must be available to reconcile managed infrastructure.
- PostgreSQL has distinct Block Volume and logical Object Storage backup layers; select a verified recovery point before any cutover.
- Sealed Secrets recovery requires protected controller key material; a new controller without the original key cannot decrypt previously sealed values.
- A single worker means maintenance or worker loss can interrupt service. The design deliberately favors low cost over high availability.
