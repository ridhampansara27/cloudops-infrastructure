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