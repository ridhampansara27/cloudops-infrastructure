# Define Terraform compatibility.
terraform {

  # Require modern Terraform.
  required_version = ">= 1.11.0"

  # Declare AWS provider.
  required_providers {

    aws = {

      # Use HashiCorp's official provider.
      source = "hashicorp/aws"

      # Stay within AWS Provider major version 6.
      version = "~> 6.0"
    }
  }
}