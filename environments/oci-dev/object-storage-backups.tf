# ============================================================
# PostgreSQL logical-backup Object Storage
# ============================================================
#
# This bucket is the durable destination for logical PostgreSQL
# backups produced separately by the Kubernetes backup CronJob.
#
# Infrastructure-level OCI Block Volume backups are managed in
# backups.tf. This bucket is intentionally an independent
# database-level recovery layer.


# ------------------------------------------------------------
# OCI Object Storage namespace
# ------------------------------------------------------------

data "oci_objectstorage_namespace" "current" {

  compartment_id = oci_identity_compartment.cloudops.id
}


# ------------------------------------------------------------
# Private PostgreSQL logical-backup bucket
# ------------------------------------------------------------

resource "oci_objectstorage_bucket" "postgres_backups" {

  compartment_id = oci_identity_compartment.cloudops.id

  namespace = data.oci_objectstorage_namespace.current.namespace

  name = "${var.project_name}-${var.environment}-postgres-backups"

  access_type = "NoPublicAccess"

  storage_tier = "Standard"

  auto_tiering = "Disabled"

  versioning = "Disabled"

  object_events_enabled = false

  freeform_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "postgres"
    Purpose     = "logical-database-backups"
  }


  # Backup storage must never disappear through an accidental
  # terraform destroy. Deliberate removal requires an explicit
  # code change first.
  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# Backup-object lifecycle policy
# ------------------------------------------------------------

resource "oci_objectstorage_object_lifecycle_policy" "postgres_backups" {

  namespace = data.oci_objectstorage_namespace.current.namespace

  bucket = oci_objectstorage_bucket.postgres_backups.name


  # Keep logical PostgreSQL recovery artifacts for thirty days.
  rules {
    action     = "DELETE"
    is_enabled = true
    name       = "delete-postgres-backups-after-30-days"
    target     = "objects"

    time_amount = 30
    time_unit   = "DAYS"
  }


  # Remove abandoned multipart uploads so interrupted uploads
  # cannot accumulate indefinitely.
  rules {
    action     = "ABORT"
    is_enabled = true
    name       = "abort-incomplete-uploads-after-3-days"
    target     = "multipart-uploads"

    time_amount = 3
    time_unit   = "DAYS"
  }
}


# ------------------------------------------------------------
# Operator-visible bucket information
# ------------------------------------------------------------

output "postgres_logical_backup_bucket_name" {

  description = "Private Object Storage bucket containing PostgreSQL logical backups."

  value = oci_objectstorage_bucket.postgres_backups.name
}


output "postgres_logical_backup_namespace" {

  description = "OCI Object Storage namespace used by the PostgreSQL backup bucket."

  value = data.oci_objectstorage_namespace.current.namespace
}