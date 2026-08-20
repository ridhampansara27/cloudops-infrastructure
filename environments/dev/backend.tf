# Store development Terraform state remotely in S3.
terraform {

  backend "s3" {

    # The bucket is supplied during terraform init.
    # Do not duplicate machine/account-specific names here.

    # Store development state under a predictable key.
    key = "environments/dev/terraform.tfstate"

    # State bucket lives in Frankfurt.
    region = "eu-central-1"

    # Enable native S3 state locking.
    use_lockfile = true

    # Enable server-side encryption.
    encrypt = true
  }
}