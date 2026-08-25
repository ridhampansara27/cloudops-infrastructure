# AWS account that Terraform is allowed to modify.
variable "aws_account_id" {

  # Require the twelve-digit AWS account ID.
  type = string
}


# AWS deployment region.
variable "aws_region" {

  # Use Frankfurt.
  type = string

  # Keep workload close to Germany.
  default = "eu-central-1"
}


# Logical environment.
variable "environment" {

  # Environment tag.
  type = string

  # Deploy development only.
  default = "dev"
}


# Name prefix for AWS resources.
variable "project_name" {

  # Project identifier.
  type = string

  # Use a readable portfolio name.
  default = "cloudops"
}


# Kubernetes version used by EKS.
variable "kubernetes_version" {

  # EKS expects the Kubernetes minor version.
  type = string

  # Use a mature version still under standard support.
  default = "1.35"
}


# CIDR allowed to access the public Kubernetes API endpoint.
variable "cluster_endpoint_public_access_cidrs" {

  # Accept one or more CIDR ranges.
  type = list(string)
}


# Worker node instance types.
variable "node_instance_types" {

  # Managed node groups support multiple candidate instance types.
  type = list(string)

  # Use x86 for compatibility with existing Docker images.
  default = [
    "t3.large",
  ]
}


# Define the IAM principal that receives Kubernetes administrator access.
variable "eks_admin_principal_arn" {

  # Expect an IAM user or role ARN.
  type = string

  # Require an explicit value.
  nullable = false
}