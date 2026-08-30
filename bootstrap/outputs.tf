# Return the Terraform state bucket name.
output "state_bucket_name" {

  # Expose the created S3 bucket.
  value = aws_s3_bucket.terraform_state.bucket
}


# Return the Terraform state bucket ARN.
output "state_bucket_arn" {

  # Expose the bucket ARN for future IAM policies.
  value = aws_s3_bucket.terraform_state.arn
}