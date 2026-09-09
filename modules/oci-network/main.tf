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
