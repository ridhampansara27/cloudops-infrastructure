# Create the S3 bucket used for Terraform state.
resource "aws_s3_bucket" "terraform_state" {

  # S3 bucket names must be globally unique.
  bucket = var.state_bucket_name

  # Prevent accidental deletion through Terraform.
  lifecycle {
    prevent_destroy = true
  }
}


# Enable versioning so accidentally overwritten state can be recovered.
resource "aws_s3_bucket_versioning" "terraform_state" {

  # Apply versioning to the state bucket.
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {

    # Keep historical Terraform state versions.
    status = "Enabled"
  }
}


# Enable server-side encryption for Terraform state.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {

  # Apply encryption to the state bucket.
  bucket = aws_s3_bucket.terraform_state.id

  rule {

    apply_server_side_encryption_by_default {

      # Use Amazon S3 managed encryption.
      sse_algorithm = "AES256"
    }
  }
}


# Block all public access to Terraform state.
resource "aws_s3_bucket_public_access_block" "terraform_state" {

  # Protect the state bucket.
  bucket = aws_s3_bucket.terraform_state.id

  # Prevent new public ACLs.
  block_public_acls = true

  # Prevent public bucket policies.
  block_public_policy = true

  # Ignore public ACLs.
  ignore_public_acls = true

  # Restrict public buckets.
  restrict_public_buckets = true
}