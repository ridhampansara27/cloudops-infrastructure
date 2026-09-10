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
