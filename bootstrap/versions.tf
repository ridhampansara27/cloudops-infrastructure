# Define Terraform and provider requirements.
terraform {

  # Require a modern Terraform release.
  required_version = ">= 1.11.0"

  # Declare providers used by the bootstrap configuration.
  required_providers {

    # Use the official HashiCorp AWS provider.
    aws = {
      source = "hashicorp/aws"

      # Stay within AWS Provider major version 6.
      version = "~> 6.0"
    }
  }
}