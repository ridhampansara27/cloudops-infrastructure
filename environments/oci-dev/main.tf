# ============================================================
# OCI environment
# ============================================================


# ------------------------------------------------------------
# Dedicated CloudOps compartment
# ------------------------------------------------------------

resource "oci_identity_compartment" "cloudops" {

  # Create the project compartment directly beneath the tenancy.
  compartment_id = var.tenancy_ocid

  name = "${var.project_name}-${var.environment}"

  description = (
    "Terraform-managed OCI compartment for the CloudOps Insight platform."
  )

  # This environment is intentionally disposable.
  enable_delete = true

  freeform_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}


# ------------------------------------------------------------
# OCI networking
# ------------------------------------------------------------

module "oci_network" {

  source = "../../modules/oci-network"

  # Explicitly pass the root Oracle OCI provider configuration
  # into the child module.
  providers = {
    oci = oci
  }

  compartment_id = oci_identity_compartment.cloudops.id

  project_name = var.project_name
  environment  = var.environment

  vcn_cidr           = var.vcn_cidr
  api_subnet_cidr    = var.api_subnet_cidr
  worker_subnet_cidr = var.worker_subnet_cidr

  kubernetes_api_allowed_cidr = var.kubernetes_api_allowed_cidr
}
