# Create the application secret container.
resource "aws_secretsmanager_secret" "application" {

  # Use a predictable environment-scoped name.
  name = (
    "/${var.project_name}/${var.environment}/application"
  )

  # Explain what belongs in this secret.
  description = (
    "CloudOps Insight runtime application secrets"
  )

  # Allow short recovery if deleted accidentally.
  recovery_window_in_days = 7

  tags = {

    # Identify ownership.
    ManagedBy = "terraform"

    # Identify environment.
    Environment = var.environment
  }
}