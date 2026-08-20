# EKS cluster name.
variable "cluster_name" {
  type = string
}


# Kubernetes version.
variable "kubernetes_version" {
  type = string
}


# Subnets used by control plane and managed nodes.
variable "subnet_ids" {

  type = list(string)
}


# EKS cluster IAM role.
variable "cluster_role_arn" {
  type = string
}


# EKS managed node IAM role.
variable "node_role_arn" {
  type = string
}


# Public API access CIDRs.
variable "endpoint_public_access_cidrs" {

  type = list(string)
}


# Worker node instance candidates.
variable "node_instance_types" {

  type = list(string)
}