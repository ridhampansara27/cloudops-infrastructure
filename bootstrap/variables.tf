# Define the AWS deployment region.
variable "aws_region" {

  # Use a string AWS region identifier.
  type = string

  # Use Frankfurt for the project.
  default = "eu-central-1"
}


# Define the globally unique Terraform state bucket name.
variable "state_bucket_name" {

  # Require a string bucket name.
  type = string

  # Do not hard-code an account-specific name here.
}