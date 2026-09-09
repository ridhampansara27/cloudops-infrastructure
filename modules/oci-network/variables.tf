variable "compartment_id" {

  description = "OCI compartment in which network resources are created."
  type        = string
}


variable "project_name" {

  description = "Project name used in OCI network resource names."
  type        = string
}


variable "environment" {

  description = "Deployment environment."
  type        = string
}


variable "vcn_cidr" {

  description = "CIDR assigned to the OCI VCN."
  type        = string
}


variable "api_subnet_cidr" {

  description = "CIDR assigned to the OKE API subnet."
  type        = string
}


variable "worker_subnet_cidr" {

  description = "CIDR assigned to the OKE worker subnet."
  type        = string
}
