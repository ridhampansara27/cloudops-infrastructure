# Return the application secret ARN.
output "application_secret_arn" {

  # Expose ARN for IAM permissions.
  value = aws_secretsmanager_secret.application.arn
}


# Return the application secret name.
output "application_secret_name" {

  # Expose secret name to GitOps configuration.
  value = aws_secretsmanager_secret.application.name
}