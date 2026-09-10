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


# ============================================================
# Cluster-specific ARM64 worker image discovery
# ============================================================

data "oci_containerengine_node_pool_option" "arm" {

  # Using the cluster ID rather than "all" ensures that the
  # returned worker options are valid for this exact cluster.
  node_pool_option_id = oci_containerengine_cluster.this.id

  compartment_id = var.compartment_id

  node_pool_k8s_version = var.kubernetes_version

  node_pool_os_arch = "AARCH64"
  node_pool_os_type = "OL8"

  should_list_all_patch_versions = true
}


locals {

  # Select only Oracle Linux 8 ARM64 OKE images that match the
  # Kubernetes version of this cluster.
  arm_oke_sources = [
    for source in data.oci_containerengine_node_pool_option.arm.sources :
    source
    if can(
      regex(
        "^Oracle-Linux-8.*aarch64.*OKE-${replace(var.kubernetes_version, "v", "")}-",
        source.source_name
      )
    )
  ]

  # OKE image names contain an ISO-style build date, so sorting
  # the names gives us a deterministic newest-compatible image.
  arm_oke_source_names = sort([
    for source in local.arm_oke_sources :
    source.source_name
  ])

  selected_arm_oke_source_name = try(
    local.arm_oke_source_names[
      length(local.arm_oke_source_names) - 1
    ],
    null
  )

  selected_arm_oke_image_id = try(
    [
      for source in local.arm_oke_sources :
      source.image_id
      if source.source_name == local.selected_arm_oke_source_name
    ][0],
    null
  )
}


# ============================================================
# OKE managed ARM64 worker node pool
# ============================================================

resource "oci_containerengine_node_pool" "arm" {

  cluster_id     = oci_containerengine_cluster.this.id
  compartment_id = var.compartment_id

  name = "${var.project_name}-${var.environment}-arm"

  kubernetes_version = var.kubernetes_version

  node_shape = var.node_shape


  # ----------------------------------------------------------
  # Ampere A1 Flex sizing
  # ----------------------------------------------------------

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_gbs
  }


  # ----------------------------------------------------------
  # OKE-managed worker image and boot volume
  # ----------------------------------------------------------

  node_source_details {
    source_type = "IMAGE"

    image_id = local.selected_arm_oke_image_id

    boot_volume_size_in_gbs = var.node_boot_volume_gbs
  }


  # ----------------------------------------------------------
  # Managed node count, networking and placement
  # ----------------------------------------------------------

  node_config_details {

    # This is the TOTAL number of nodes in the pool,
    # not the number of nodes per availability domain.
    size = var.node_count

    nsg_ids = [
      var.worker_nsg_id,
    ]

    # Explicitly keep the worker-node CNI aligned with the
    # cluster's Flannel Overlay configuration.
    node_pool_pod_network_option_details {
      cni_type = "FLANNEL_OVERLAY"
    }

    # The worker subnet is regional, therefore every Frankfurt
    # AD can reference the same subnet.
    dynamic "placement_configs" {

      for_each = var.availability_domains

      content {
        availability_domain = placement_configs.value
        subnet_id           = var.worker_subnet_id
      }
    }

    freeform_tags = local.common_tags
  }


  freeform_tags = local.common_tags


  lifecycle {

    # Fail planning if OCI no longer exposes a compatible
    # AARCH64 Oracle Linux 8 OKE image for this cluster.
    precondition {
      condition     = local.selected_arm_oke_image_id != null
      error_message = "No compatible ARM64 Oracle Linux 8 OKE worker image was found."
    }

    # This platform currently depends on all Frankfurt ADs being
    # eligible so OCI has the widest possible placement choice.
    precondition {
      condition     = length(var.availability_domains) == 3
      error_message = "The OCI development node pool expects exactly three Frankfurt availability domains."
    }
  }


  timeouts {
    create = "60m"
    update = "120m"
    delete = "60m"
  }
}
