# Project name used in resource names.
variable "project_name" {
  type = string
}


# Environment identifier.
variable "environment" {
  type = string
}


# VPC CIDR range.
variable "vpc_cidr" {

  type = string

  default = "10.60.0.0/16"
}


# Availability zones used by EKS.
variable "availability_zones" {

  type = list(string)
}


# Control whether production-oriented private application subnets exist.
variable "create_private_subnets" {

  # Enable only for production-oriented environments.
  type = bool

  # Keep low-cost development behavior.
  default = false
}


# Control whether isolated database subnets exist.
variable "create_database_subnets" {

  # Enable when managed database services are deployed.
  type = bool

  # Keep development inexpensive.
  default = false
}