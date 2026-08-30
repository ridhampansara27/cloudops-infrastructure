# Configure AWS for GitHub Actions OIDC bootstrap resources.
provider "aws" {

  region = var.aws_region

  default_tags {

    tags = {
      Project     = "cloudops-insight"
      ManagedBy   = "terraform"
      Environment = "shared"
      Component   = "github-oidc"
    }
  }
}