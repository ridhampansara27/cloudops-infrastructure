# Define project name.
variable "project_name" {
  type = string
}


# Define environment.
variable "environment" {
  type = string
}


# Define private database subnet IDs.
variable "subnet_ids" {
  type = list(string)
}


# Define the VPC.
variable "vpc_id" {
  type = string
}


# Define the security group allowed to connect from EKS.
variable "eks_security_group_id" {
  type = string
}


# Define development versus production availability.
variable "multi_az" {

  # Allow environment-specific configuration.
  type = bool

  # Avoid unnecessary development cost by default.
  default = false
}