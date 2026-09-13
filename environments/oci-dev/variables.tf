# ------------------------------------------------------------
# OCI authentication / tenancy
# ------------------------------------------------------------

variable "oci_profile" {

  description = "OCI CLI configuration profile used by Terraform."
  type        = string
  default     = "CLOUDOPS"
}


variable "oci_region" {

  description = "OCI region hosting the CloudOps environment."
  type        = string
  default     = "eu-frankfurt-1"
}


variable "tenancy_ocid" {

  description = "Root OCI tenancy OCID."
  type        = string
}


# ------------------------------------------------------------
# Project metadata
# ------------------------------------------------------------

variable "project_name" {

  description = "Project name used for OCI resource naming."
  type        = string
  default     = "cloudops-insight"
}


variable "environment" {

  description = "Deployment environment."
  type        = string
  default     = "oci-dev"
}


# ------------------------------------------------------------
# Network design
# ------------------------------------------------------------

variable "vcn_cidr" {

  description = "CIDR assigned to the CloudOps OCI VCN."
  type        = string
  default     = "10.70.0.0/16"
}


variable "api_subnet_cidr" {

  description = "CIDR reserved for the OKE Kubernetes API endpoint."
  type        = string
  default     = "10.70.0.0/28"
}


variable "worker_subnet_cidr" {

  description = "CIDR used by the OKE worker node subnet."
  type        = string
  default     = "10.70.10.0/24"
}

variable "kubernetes_api_allowed_cidr" {
  description = "IPv4 CIDR allowed to access the public Kubernetes API endpoint."
  type        = string
}

# ============================================================
# OKE control-plane configuration
# ============================================================

variable "oke_kubernetes_version" {
  description = "Kubernetes version for the OCI OKE cluster."
  type        = string
  default     = "v1.35.2"
}

variable "oke_pods_cidr" {
  description = "Pod network CIDR used by Flannel Overlay."
  type        = string
  default     = "10.244.0.0/16"
}

variable "oke_services_cidr" {
  description = "Kubernetes Service CIDR."
  type        = string
  default     = "10.96.0.0/16"
}
