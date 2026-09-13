# ============================================================
# Retired AWS development environment
# ============================================================
#
# This Terraform environment previously managed the CloudOps
# Insight AWS EKS development platform.
#
# The AWS runtime was retired after production migrated to
# OCI OKE. No infrastructure resources or cloud providers are
# intentionally declared here.
#
# backend.tf is retained only so the historical, now-empty
# remote Terraform state remains addressable when required.

terraform {
  required_version = ">= 1.11.0"
}