# Contributing

1. Branch from current `main`. Keep OCI and historical AWS changes separate.
2. Run `terraform fmt -check -recursive`, backend-disabled OCI `terraform validate`, and the repository PR checks. Do not commit `.tfvars`, state, plan files, or OCI CLI configuration.
3. Describe resource changes, replacement/destruction risk, backup and state implications, cost impact, and rollback/recovery approach in the PR.
4. Treat a green `Terraform plan` status as an AWS tombstone safety check, not as approval or an OCI cloud-connected plan.
5. Make production plan/apply decisions only after an authenticated operator reviews current remote state and the actual OCI plan.

Preserve the retired AWS environment tombstone and existing state references until their recovery value has been explicitly reviewed.
