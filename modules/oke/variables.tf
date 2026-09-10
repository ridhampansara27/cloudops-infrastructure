variable "compartment_id" {
  description = "OCID of the compartment that contains the OKE cluster."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN used by OKE."
  type        = string
}

variable "api_subnet_id" {
  description = "OCID of the regional subnet used by the Kubernetes API endpoint."
  type        = string
}

variable "api_nsg_id" {
  description = "OCID of the Network Security Group attached to the Kubernetes API endpoint."
  type        = string
}

variable "project_name" {
  description = "Project name used for OCI naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name used for OCI naming and tags."
  type        = string
}

variable "kubernetes_version" {
  description = "OKE Kubernetes version."
  type        = string
}

variable "pods_cidr" {
  description = "IPv4 CIDR used by Flannel-managed Kubernetes pods."
  type        = string

  validation {
    condition     = can(cidrhost(var.pods_cidr, 0))
    error_message = "pods_cidr must be a valid IPv4 CIDR."
  }
}

variable "services_cidr" {
  description = "IPv4 CIDR used by Kubernetes Services."
  type        = string

  validation {
    condition     = can(cidrhost(var.services_cidr, 0))
    error_message = "services_cidr must be a valid IPv4 CIDR."
  }
}

# ============================================================
# OKE managed worker-node configuration
# ============================================================

variable "worker_subnet_id" {
  description = "OCID of the regional subnet used by OKE managed worker nodes."
  type        = string
}

variable "worker_nsg_id" {
  description = "OCID of the NSG attached to OKE managed worker nodes."
  type        = string
}

variable "availability_domains" {
  description = "Availability domains eligible for worker-node placement."
  type        = list(string)

  validation {
    condition     = length(var.availability_domains) > 0
    error_message = "At least one availability domain must be supplied."
  }
}

variable "node_count" {
  description = "Total number of managed worker nodes."
  type        = number

  validation {
    condition     = var.node_count >= 1 && floor(var.node_count) == var.node_count
    error_message = "node_count must be a positive integer."
  }
}

variable "node_shape" {
  description = "OCI Compute shape used by OKE managed worker nodes."
  type        = string
}

variable "node_ocpus" {
  description = "Number of OCPUs allocated to each flexible worker node."
  type        = number

  validation {
    condition     = var.node_ocpus > 0
    error_message = "node_ocpus must be greater than zero."
  }
}

variable "node_memory_gbs" {
  description = "Memory in GB allocated to each flexible worker node."
  type        = number

  validation {
    condition     = var.node_memory_gbs > 0
    error_message = "node_memory_gbs must be greater than zero."
  }
}

variable "node_boot_volume_gbs" {
  description = "Boot-volume size in GB for each managed worker node."
  type        = number

  validation {
    condition     = var.node_boot_volume_gbs >= 50
    error_message = "OKE worker boot volumes must be at least 50 GB."
  }
}
