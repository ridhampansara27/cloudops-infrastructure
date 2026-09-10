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


# ============================================================
# OCI Kubernetes Engine
# ============================================================

module "oke" {

  source = "../../modules/oke"

  providers = {
    oci = oci
  }

  compartment_id = oci_identity_compartment.cloudops.id

  vcn_id        = module.oci_network.vcn_id
  api_subnet_id = module.oci_network.api_subnet_id
  api_nsg_id    = module.oci_network.api_nsg_id

  worker_subnet_id = module.oci_network.worker_subnet_id
  worker_nsg_id    = module.oci_network.worker_nsg_id

  availability_domains = [
    for ad in data.oci_identity_availability_domains.current.availability_domains :
    ad.name
  ]

  # ----------------------------------------------------------
  # OCI Always Free worker cost guard
  # ----------------------------------------------------------
  #
  # These values are intentionally hard-coded for oci-dev.
  # Changing a local tfvars file therefore cannot accidentally
  # scale this environment beyond the intended architecture.

  node_count           = 1
  node_shape           = "VM.Standard.A1.Flex"
  node_ocpus           = 2
  node_memory_gbs      = 12
  node_boot_volume_gbs = 50

  project_name = var.project_name
  environment  = var.environment

  kubernetes_version = var.oke_kubernetes_version

  pods_cidr     = var.oke_pods_cidr
  services_cidr = var.oke_services_cidr

  # Important for a clean bootstrap:
  # all network resources and their NSG rules must exist
  # before OCI starts provisioning the control plane.
  depends_on = [
    module.oci_network,
  ]
}

