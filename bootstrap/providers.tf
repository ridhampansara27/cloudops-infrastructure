# Configure the AWS provider.
provider "aws" {

  # Deploy the platform in Frankfurt.
  region = var.aws_region

  # Apply common resource tags.
  default_tags {
    tags = {

      # Identify the portfolio project.
      Project = "cloudops-insight"

      # Identify infrastructure ownership.
      ManagedBy = "terraform"

      # Identify this as shared Terraform state infrastructure.
      Environment = "shared"
    }
  }
}