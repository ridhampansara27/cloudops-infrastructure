# ============================================================
# CloudOps OCI network module
# ============================================================


locals {

  # Apply consistent ownership metadata across OCI resources.
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}


# ------------------------------------------------------------
# Virtual Cloud Network
# ------------------------------------------------------------

resource "oci_core_vcn" "this" {

  compartment_id = var.compartment_id

  # Use cidr_blocks rather than the deprecated cidr_block
  # argument for the VCN itself.
  cidr_blocks = [
    var.vcn_cidr,
  ]

  display_name = "${var.project_name}-${var.environment}-vcn"

  # Required for OCI VCN DNS resolution.
  dns_label = "cloudops"

  freeform_tags = local.common_tags
}


# ------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------

resource "oci_core_internet_gateway" "this" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.project_name}-${var.environment}-igw"

  enabled = true

  freeform_tags = local.common_tags
}


# ------------------------------------------------------------
# Public routing
# ------------------------------------------------------------

resource "oci_core_route_table" "public" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.project_name}-${var.environment}-public"

  # Send public IPv4 traffic through the Internet Gateway.
  route_rules {

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    network_entity_id = oci_core_internet_gateway.this.id
  }

  freeform_tags = local.common_tags
}


# ------------------------------------------------------------
# Restrictive base security list
# ------------------------------------------------------------

resource "oci_core_security_list" "base" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.project_name}-${var.environment}-base"

  # Permit outbound traffic.
  #
  # No ingress rule is intentionally defined here.
  # OKE-specific inbound access will be controlled using NSGs.
  egress_security_rules {

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    protocol = "all"

    description = "Allow outbound IPv4 traffic."

    stateless = false
  }

  freeform_tags = local.common_tags
}


# ------------------------------------------------------------
# Kubernetes API subnet
# ------------------------------------------------------------

resource "oci_core_subnet" "api" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  cidr_block = var.api_subnet_cidr

  display_name = "${var.project_name}-${var.environment}-api"

  dns_label = "api"

  # Keep the subnet regional by deliberately omitting
  # availability_domain.
  #
  # The public OKE API endpoint will later be created here.
  prohibit_public_ip_on_vnic = false

  route_table_id = oci_core_route_table.public.id

  # Avoid inheriting OCI's default VCN security list.
  security_list_ids = [
    oci_core_security_list.base.id,
  ]

  freeform_tags = local.common_tags
}


# ------------------------------------------------------------
# OKE worker subnet
# ------------------------------------------------------------

resource "oci_core_subnet" "workers" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  cidr_block = var.worker_subnet_cidr

  display_name = "${var.project_name}-${var.environment}-workers"

  dns_label = "workers"

  # Public IP eligibility intentionally avoids a NAT Gateway
  # for this low-cost portfolio environment.
  #
  # Public IP eligibility does NOT itself permit inbound
  # traffic; security rules remain restrictive.
  prohibit_public_ip_on_vnic = false

  route_table_id = oci_core_route_table.public.id

  security_list_ids = [
    oci_core_security_list.base.id,
  ]

  freeform_tags = local.common_tags
}


# ------------------------------------------------------------
# Kubernetes API Network Security Group
# ------------------------------------------------------------

resource "oci_core_network_security_group" "api" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.project_name}-${var.environment}-api-nsg"

  # Rules are intentionally added during the OKE stage,
  # where we can implement Oracle's exact Kubernetes
  # control-plane requirements.
  freeform_tags = local.common_tags
}


# ------------------------------------------------------------
# Worker Network Security Group
# ------------------------------------------------------------

resource "oci_core_network_security_group" "workers" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.project_name}-${var.environment}-workers-nsg"

  # No Internet-facing application ports are opened here.
  #
  # Cloudflare Tunnel will later originate outbound traffic
  # from inside the Kubernetes cluster.
  freeform_tags = local.common_tags
}

# ============================================================
# OKE Network Security Group rules
# ============================================================


# ------------------------------------------------------------
# Kubernetes API endpoint ingress
# ------------------------------------------------------------

resource "oci_core_network_security_group_security_rule" "api_from_workers_6443" {

  network_security_group_id = oci_core_network_security_group.api.id

  direction   = "INGRESS"
  protocol    = "6"
  source      = var.worker_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  description = "Allow OKE workers to access Kubernetes API port 6443."

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}


resource "oci_core_network_security_group_security_rule" "api_from_workers_12250" {

  network_security_group_id = oci_core_network_security_group.api.id

  direction   = "INGRESS"
  protocol    = "6"
  source      = var.worker_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  description = "Allow OKE workers to communicate with control plane port 12250."

  tcp_options {
    destination_port_range {
      min = 12250
      max = 12250
    }
  }
}


resource "oci_core_network_security_group_security_rule" "api_path_discovery" {

  network_security_group_id = oci_core_network_security_group.api.id

  direction   = "INGRESS"
  protocol    = "1"
  source      = var.worker_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  description = "Allow ICMP fragmentation-needed messages from worker subnet."

  icmp_options {
    type = 3
    code = 4
  }
}


resource "oci_core_network_security_group_security_rule" "api_from_admin" {

  network_security_group_id = oci_core_network_security_group.api.id

  direction   = "INGRESS"
  protocol    = "6"
  source      = var.kubernetes_api_allowed_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  description = "Allow restricted administrative access to Kubernetes API."

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}


# ------------------------------------------------------------
# OKE worker ingress
# ------------------------------------------------------------

resource "oci_core_network_security_group_security_rule" "workers_from_workers" {

  network_security_group_id = oci_core_network_security_group.workers.id

  direction   = "INGRESS"
  protocol    = "all"
  source      = var.worker_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  description = "Allow communication between OKE worker nodes."
}


resource "oci_core_network_security_group_security_rule" "workers_from_api" {

  network_security_group_id = oci_core_network_security_group.workers.id

  direction   = "INGRESS"
  protocol    = "6"
  source      = var.api_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  # No destination-port restriction intentionally means TCP/ALL,
  # matching Oracle's Flannel requirement.
  description = "Allow Kubernetes API endpoint TCP communication to workers."
}


resource "oci_core_network_security_group_security_rule" "workers_path_discovery" {

  network_security_group_id = oci_core_network_security_group.workers.id

  direction   = "INGRESS"
  protocol    = "1"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  description = "Allow ICMP fragmentation-needed messages for path discovery."

  icmp_options {
    type = 3
    code = 4
  }
}
