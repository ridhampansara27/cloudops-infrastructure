# S3 bucket containing the Terraform remote state.
variable "state_bucket_name" {

  type = string

  description = (
    "Name of the S3 bucket containing the CloudOps Terraform state."
  )
}

# AWS region used by the CloudOps platform.
variable "aws_region" {

  type = string

  default = "eu-central-1"

  description = (
    "AWS region used by the CloudOps infrastructure."
  )
}