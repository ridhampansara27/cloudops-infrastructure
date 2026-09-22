# ============================================================
# Object Storage lifecycle service authorization
# ============================================================
#
# OCI Object Lifecycle Management runs as the regional Object
# Storage service principal.
#
# The policy itself must live in the tenancy root compartment,
# while the granted permissions are restricted to the CloudOps
# environment compartment.
#
# This policy deliberately grants only the permissions required
# by the current lifecycle rules:
#
# - inspect/read the bucket
# - inspect objects
# - delete objects / abort incomplete multipart uploads
#
# It does NOT grant object creation, object reads, tier changes,
# bucket mutation, previous-version deletion, or general bucket
# administration.


resource "oci_identity_policy" "object_storage_lifecycle" {

  # OCI lifecycle service authorization policies must be created
  # at the tenancy/root compartment.
  compartment_id = var.tenancy_ocid

  name = "${var.project_name}-${var.environment}-object-storage-lifecycle"

  description = "Least-privilege authorization for the regional OCI Object Storage service to execute PostgreSQL backup lifecycle rules."

  statements = [
    join(
      " ",
      [
        "Allow service objectstorage-${var.oci_region}",
        "to manage object-family",
        "in compartment id ${oci_identity_compartment.cloudops.id}",
        "where any {",
        "request.permission='BUCKET_INSPECT',",
        "request.permission='BUCKET_READ',",
        "request.permission='OBJECT_INSPECT',",
        "request.permission='OBJECT_DELETE'",
        "}"
      ]
    )
  ]

  freeform_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "object-storage"
    Purpose     = "lifecycle-service-authorization"
  }


  # Avoid accidental removal of the service authorization while
  # lifecycle-managed backup storage is still in use.
  lifecycle {
    prevent_destroy = true
  }
}
