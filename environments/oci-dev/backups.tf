# ============================================================
# PostgreSQL Block Volume backup protection
# ============================================================
#
# The PostgreSQL PersistentVolume is dynamically provisioned
# by the OCI Block Volume CSI driver, so Terraform does not
# create the volume itself.
#
# Its existing OCI Block Volume OCID is supplied through the
# local, Git-ignored terraform.tfvars file.
#
# This policy provides infrastructure-level disaster recovery.
# Logical PostgreSQL backups are managed separately.


# ------------------------------------------------------------
# Existing PostgreSQL Block Volume
# ------------------------------------------------------------

variable "postgres_volume_id" {

  description = "OCI Block Volume OCID backing the production PostgreSQL PVC."
  type        = string

  validation {
    condition = can(
      regex(
        "^ocid1\\.volume\\.",
        var.postgres_volume_id
      )
    )

    error_message = "postgres_volume_id must be an OCI Block Volume OCID."
  }
}


# ------------------------------------------------------------
# PostgreSQL backup policy
# ------------------------------------------------------------

resource "oci_core_volume_backup_policy" "postgres" {

  compartment_id = oci_identity_compartment.cloudops.id

  display_name = "${var.project_name}-${var.environment}-postgres"

  # ----------------------------------------------------------
  # Daily incremental backup
  #
  # Run at 02:00 regional data-center time and retain each
  # daily recovery point for seven days.
  # ----------------------------------------------------------

  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    retention_seconds = 604800

    offset_type = "STRUCTURED"
    hour_of_day = 2
    time_zone   = "REGIONAL_DATA_CENTER_TIME"
  }


  # ----------------------------------------------------------
  # Weekly incremental backup
  #
  # Run Sunday at 03:00 and retain each weekly recovery point
  # for twenty-eight days.
  # ----------------------------------------------------------

  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_WEEK"
    retention_seconds = 2419200

    offset_type = "STRUCTURED"
    day_of_week = "SUNDAY"
    hour_of_day = 3
    time_zone   = "REGIONAL_DATA_CENTER_TIME"
  }


  freeform_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "postgres"
    Purpose     = "disaster-recovery"
  }
}


# ------------------------------------------------------------
# Assign policy to the existing PostgreSQL OCI Block Volume
# ------------------------------------------------------------

resource "oci_core_volume_backup_policy_assignment" "postgres" {

  asset_id = var.postgres_volume_id

  policy_id = oci_core_volume_backup_policy.postgres.id
}


# ------------------------------------------------------------
# Operator-visible backup identifiers
# ------------------------------------------------------------

output "postgres_volume_backup_policy_id" {

  description = "OCID of the PostgreSQL Block Volume backup policy."
  value       = oci_core_volume_backup_policy.postgres.id
}


output "postgres_volume_backup_policy_assignment_id" {

  description = "OCID of the PostgreSQL volume backup-policy assignment."
  value       = oci_core_volume_backup_policy_assignment.postgres.id
}