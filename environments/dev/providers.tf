# Retrieve the AWS account Terraform is using.
data "aws_caller_identity" "current" {}


# Configure AWS.
provider "aws" {

  # Use the configured project region.
  region = var.aws_region

  # Protect against accidentally deploying into the wrong AWS account.
  allowed_account_ids = [
    var.aws_account_id,
  ]

  # Apply consistent tags.
  default_tags {

    tags = {

      # Identify the project.
      Project = "cloudops-insight"

      # Identify environment.
      Environment = var.environment

      # Identify IaC ownership.
      ManagedBy = "terraform"

      # Make demo resources easy to locate before destruction.
      Temporary = "true"
    }
  }
}