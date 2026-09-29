# OCI recovery dependencies

## Terraform state

The active `oci` backend stores state in a separately provisioned Object Storage bucket. Maintain restricted access and an independent state-bucket recovery plan. If state is unavailable, preserve the cloud resources and recover the correct state object/version before any plan or import. Never initialize a new empty state and apply it against existing production resources without reconciliation.

## PostgreSQL

The PostgreSQL PVC uses OCI Block Volume. Terraform assigns daily incremental backups retained seven days and weekly incremental backups retained 28 days. The GitOps CronJob separately uploads custom-format logical dumps to a private bucket with 30-day lifecycle deletion. Verify the latest backup and restore a selected recovery point to an **isolated target** before planning a production cutover. See the [GitOps database runbook](https://github.com/ridhampansara27/cloudops-gitops/blob/main/docs/runbooks/postgres-recovery.md).

## Sealed Secrets

The protected OCI Vault/key resources are part of controller key recovery, not a substitute for a tested recovery procedure. Confirm authorized access to recovery material and restore the original controller key before expecting existing Sealed Secrets to decrypt. Do not delete or recreate the controller key casually.

## OKE service restoration

Confirm VCN/API access, node pool, Block Volume attachment, Argo CD application tree, external Kubernetes Secrets, tunnel connector, backend readiness, workers, and a current backup. Distinguish infrastructure recovery from GitOps workload reconciliation. Record recovery time, data recovery point, and any customer impact. Changes to live state or data require a separately approved incident plan.
