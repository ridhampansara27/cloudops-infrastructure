# Infrastructure milestones

## 2026-09-29 — Certified OCI commercial hosting baseline

- Repository commit `54ddda1611a036a60250fa8e49ab3f1bd36b468d`.
- OKE Basic cluster with one ARM A1 worker, Cloudflare Tunnel application route, PostgreSQL Block Volume protection, private logical-backup Object Storage bucket, and Sealed Secrets recovery Vault/key.
- Application and GitOps certification is recorded in their respective repositories.

## Historical AWS hosting

EKS hosting was retired after OCI migration. `environments/dev/` remains an inert tombstone, while its cost and demonstration notes are preserved under `docs/history/`.
