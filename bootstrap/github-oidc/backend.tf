# Store GitHub OIDC bootstrap state remotely.
terraform {

  backend "s3" {

    key = "bootstrap/github-oidc/terraform.tfstate"

    region = "eu-central-1"

    use_lockfile = true

    encrypt = true
  }
}