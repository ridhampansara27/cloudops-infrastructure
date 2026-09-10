# ============================================================
# OCI Kubernetes Engine - Basic control plane
# ============================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}


resource "oci_containerengine_cluster" "this" {

  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  name = "${var.project_name}-${var.environment}-oke"

  kubernetes_version = var.kubernetes_version

  # Cost guard:
  # Keep the control plane explicitly on the free Basic tier.
  # Do not rely on OCI defaults.
  type = "BASIC_CLUSTER"


  # ----------------------------------------------------------
  # Pod networking
  # ----------------------------------------------------------

  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }


  # ----------------------------------------------------------
  # Kubernetes API endpoint
  # ----------------------------------------------------------

  endpoint_config {

    # The API endpoint receives a public IP, but inbound
    # TCP/6443 is restricted by the API NSG.
    is_public_ip_enabled = true

    subnet_id = var.api_subnet_id

    nsg_ids = [
      var.api_nsg_id,
    ]
  }


  # ----------------------------------------------------------
  # Kubernetes network ranges
  # ----------------------------------------------------------

  options {

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
  }


  freeform_tags = local.common_tags


  timeouts {
    create = "45m"
    update = "120m"
    delete = "45m"
  }
}
