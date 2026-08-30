# CloudOps Insight Infrastructure

Terraform infrastructure for the CloudOps Insight GitOps-based
Kubernetes platform.

## Architecture

- Amazon EKS
- AWS VPC
- Multi-AZ subnets
- EKS Managed Node Groups
- EKS Pod Identity
- AWS Load Balancer Controller
- S3 remote Terraform state
- EKS access entries
- GitHub Actions OIDC

## Repositories

### cloudops-insight
Application source, backend/frontend tests, Docker image CI.

### cloudops-gitops
Helm chart, environment values, Argo CD applications.

### cloudops-infrastructure
AWS infrastructure managed with Terraform.

## Environments

### dev

Cost-optimized demonstration environment:
- Public EKS worker nodes.
- No NAT Gateway.
- PostgreSQL inside Kubernetes.
- Redis inside Kubernetes.
- Short-lived EKS cluster.
- Destroyed after demonstrations.

### production target

Production-oriented architecture:
- Private worker subnets.
- Public ALB subnets.
- RDS PostgreSQL.
- ElastiCache Valkey.
- Secrets Manager.
- External Secrets Operator.
- ACM TLS.
- Route53 optional DNS.

## Terraform workflow

Pull Request:
1. terraform fmt
2. terraform validate
3. Trivy IaC
4. terraform plan

Apply:
1. Manual GitHub Actions workflow
2. Protected GitHub Environment approval
3. OIDC temporary AWS credentials
4. terraform plan
5. terraform apply

## Security

- No permanent AWS credentials in GitHub.
- GitHub Actions uses OIDC.
- EKS workloads use Pod Identity.
- EKS admin access uses access entries.
- IMDSv2 required on nodes.
- Terraform remote state is versioned and encrypted.
- Secrets are not committed to Git.