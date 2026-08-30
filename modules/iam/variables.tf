# Project identifier.
variable "project_name" {
  type = string
}


# Environment identifier.
variable "environment" {
  type = string
}


# AWS IAM roles that the CloudOps workload may assume for
# external/customer AWS account discovery.
variable "cloudops_discovery_role_arns" {

  type = list(string)

  default = []

  description = (
    "IAM role ARNs that the CloudOps workload may assume for AWS discovery."
  )
}