# OCI Terraform change runbook

**Scope:** Active `environments/oci-dev`. Cloud-connected commands affect the commercial hosting platform and require explicit operator authorization.

1. Record current Git commit, Terraform state location, OCI account/profile, compartment, Kubernetes context, and a recent successful database backup.
2. From a clean branch, review the Terraform diff and lockfile. Run `terraform fmt -check -recursive`, `terraform init -backend=false`, `terraform validate`, and the PR CI/Trivy checks.
3. After PR review, use the authorized OCI CLI profile and remote backend to create a cloud-connected plan. Check every `create`, `update`, `replace`, and `destroy`, especially OKE, volume policy, Object Storage, Vault, and IAM.
4. Save the reviewed plan securely. Apply only that reviewed plan under the approved maintenance procedure; observe Terraform output, OKE health, Argo CD, application readiness, and backup jobs.
5. Record the Git commit, state version, reviewed plan summary, operator, and post-change evidence.

The CI status named `Terraform plan` is a safety gate for the retired AWS tombstone and does **not** perform an OCI cloud plan. Do not infer OCI drift status from that green check. Protected backup bucket and Vault/key resources use `prevent_destroy`; do not bypass it during routine cleanup.
