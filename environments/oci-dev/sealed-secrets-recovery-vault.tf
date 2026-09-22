# ============================================================
# Sealed Secrets disaster-recovery encryption store
# ============================================================
#
# This Vault and master encryption key protect out-of-band
# recovery copies of Sealed Secrets controller private keys.
#
# IMPORTANT:
# - Sealed Secrets private key material is NOT managed here.
# - Secret payloads must never be placed in Terraform.
# - The recovery Secret itself will be created separately.
# ============================================================


# ------------------------------------------------------------
# Standard OCI Vault
# ------------------------------------------------------------

resource "oci_kms_vault" "sealed_secrets_recovery" {

  compartment_id = oci_identity_compartment.cloudops.id

  display_name = "${var.project_name}-${var.environment}-sealed-secrets-recovery"

  # DEFAULT uses OCI's standard multitenant Vault service.
  # Do not use VIRTUAL_PRIVATE because that has separate
  # hourly pricing and is unnecessary for this workload.
  vault_type = "DEFAULT"

  freeform_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "sealed-secrets"
    Purpose     = "disaster-recovery"
  }


  # A recovery encryption root must not disappear through a
  # routine Terraform destroy.
  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# Software-protected AES-256 master encryption key
# ------------------------------------------------------------

resource "oci_kms_key" "sealed_secrets_recovery" {

  compartment_id = oci_identity_compartment.cloudops.id

  display_name = "${var.project_name}-${var.environment}-sealed-secrets-recovery"

  # OCI keys are created through the Vault management endpoint.
  management_endpoint = oci_kms_vault.sealed_secrets_recovery.management_endpoint

  # Software protection avoids HSM key-version cost while still
  # keeping the key protected by OCI Vault.
  protection_mode = "SOFTWARE"

  key_shape {
    algorithm = "AES"

    # AES-256 = 32 bytes.
    length = 32
  }

  freeform_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "sealed-secrets"
    Purpose     = "disaster-recovery"
  }


  # This key protects disaster-recovery material and therefore
  # must require an explicit code change before destruction.
  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# Operator-visible identifiers
# ------------------------------------------------------------

output "sealed_secrets_recovery_vault_id" {

  description = "OCI Vault OCID used for Sealed Secrets disaster-recovery material."

  value = oci_kms_vault.sealed_secrets_recovery.id
}


output "sealed_secrets_recovery_key_id" {

  description = "Software-protected OCI master key used to encrypt Sealed Secrets recovery secrets."

  value = oci_kms_key.sealed_secrets_recovery.id
}