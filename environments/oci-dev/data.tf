# ------------------------------------------------------------
# OCI tenancy discovery
# ------------------------------------------------------------

# Discover the Availability Domains available to this tenancy.
#
# This is a read-only data source and creates no OCI resources.
data "oci_identity_availability_domains" "current" {

  compartment_id = var.tenancy_ocid
}
