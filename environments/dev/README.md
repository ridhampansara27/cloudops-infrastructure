# Retired AWS Development Environment

This directory is intentionally retained as a tombstone for the former
CloudOps Insight AWS EKS development environment.

## Status

**Retired. Do not recreate.**

Production now runs on OCI OKE and is exposed through Cloudflare Tunnel.

The former AWS platform included:

- Amazon EKS
- EC2 managed worker nodes
- AWS Load Balancer Controller
- EBS CSI
- EKS Pod Identity
- Secrets Manager
- ACM
- dedicated VPC networking

Those runtime resources were removed after the OCI production migration
was validated.

## Terraform state

`backend.tf` is retained so the historical remote state location remains
documented and addressable. The state contains no managed runtime
resources after retirement.

This environment intentionally contains **no Terraform resources,
modules, providers, variables, or outputs**.

Do not add new AWS production infrastructure here. New production
infrastructure belongs to the OCI environment under:

`environments/oci-dev`