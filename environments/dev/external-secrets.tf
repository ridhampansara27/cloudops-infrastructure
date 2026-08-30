# ------------------------------------------------------------
# External Secrets Pod Identity trust policy
# ------------------------------------------------------------

data "aws_iam_policy_document" "external_secrets_assume_role" {

  statement {

    # Allow EKS Pod Identity.
    effect = "Allow"

    principals {

      # Trust the EKS Pod Identity service.
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com",
      ]
    }

    # Allow the required Pod Identity STS operations.
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
  }
}


# ------------------------------------------------------------
# External Secrets IAM role
# ------------------------------------------------------------

resource "aws_iam_role" "external_secrets" {

  # Use an environment-specific role name.
  name = (
    "${var.project_name}-${var.environment}-external-secrets"
  )

  # Trust EKS Pod Identity.
  assume_role_policy = (
    data.aws_iam_policy_document.external_secrets_assume_role.json
  )
}


# Grant access only to the CloudOps application secret.
data "aws_iam_policy_document" "external_secrets" {

  statement {

    # Permit Secrets Manager read operations.
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    # Restrict access to the CloudOps application secret.
    resources = [
      module.secrets.application_secret_arn,
    ]
  }
}


# Create the permission policy.
resource "aws_iam_policy" "external_secrets" {

  # Give the policy a readable name.
  name = (
    "${var.project_name}-${var.environment}-external-secrets"
  )

  # Store generated IAM JSON.
  policy = (
    data.aws_iam_policy_document.external_secrets.json
  )
}


# Attach permission to the ESO Pod Identity role.
resource "aws_iam_role_policy_attachment" "external_secrets" {

  # Attach to the controller role.
  role = aws_iam_role.external_secrets.name

  # Supply the Secrets Manager read policy.
  policy_arn = aws_iam_policy.external_secrets.arn
}


# Associate the role with the ESO controller ServiceAccount.
resource "aws_eks_pod_identity_association" "external_secrets" {

  # Use the CloudOps EKS cluster.
  cluster_name = module.eks.cluster_name

  # ESO runs in its dedicated namespace.
  namespace = "external-secrets"

  # Match the Helm chart's ServiceAccount.
  service_account = "external-secrets"

  # Supply the AWS secret-reader role.
  role_arn = aws_iam_role.external_secrets.arn
}