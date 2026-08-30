# Register GitHub Actions as an AWS OIDC identity provider.
resource "aws_iam_openid_connect_provider" "github" {

  # GitHub Actions token issuer.
  url = "https://token.actions.githubusercontent.com"

  # AWS STS is the required audience.
  client_id_list = [
    "sts.amazonaws.com",
  ]
}


# Read the AWS account where the GitHub OIDC roles are created.
data "aws_caller_identity" "current" {}


# ============================================================
# GitHub Actions Terraform PR plan role
# ============================================================

# Build trust rules for Terraform PR planning.
data "aws_iam_policy_document" "github_plan_assume_role" {

  statement {

    # Allow GitHub's OIDC provider.
    effect = "Allow"

    principals {

      # Use Web Identity federation.
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn,
      ]
    }

    # Permit short-lived GitHub OIDC sessions.
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]


    # --------------------------------------------------------
    # Validate the OIDC audience.
    #
    # aws-actions/configure-aws-credentials requests the token
    # for AWS STS, therefore the audience must remain:
    #
    # sts.amazonaws.com
    # --------------------------------------------------------
    condition {

      test = "StringEquals"

      variable = (
        "token.actions.githubusercontent.com:aud"
      )

      values = [
        "sts.amazonaws.com",
      ]
    }


    # --------------------------------------------------------
    # Restrict access to pull-request workflows from this
    # exact GitHub repository.
    #
    # GitHub immutable OIDC subjects include:
    #
    #   repository owner name
    #   repository owner numeric ID
    #   repository name
    #   repository numeric ID
    #
    # This prevents a renamed/recreated repository from
    # inheriting access to this AWS role.
    # --------------------------------------------------------
    condition {

      test = "StringEquals"

      variable = (
        "token.actions.githubusercontent.com:sub"
      )

      values = [
        "repo:ridhampansara27@70193760/cloudops-infrastructure@1321840627:pull_request",
      ]
    }
  }
}


# ============================================================
# GitHub Actions Terraform apply role
# ============================================================

# Build the OIDC trust policy used by approved Terraform applies.
data "aws_iam_policy_document" "github_apply_assume_role" {

  statement {

    sid = "AllowGitHubTerraformApply"

    effect = "Allow"

    principals {

      # Trust the GitHub Actions OIDC provider.
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn,
      ]
    }

    # Permit short-lived GitHub OIDC sessions.
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]


    # --------------------------------------------------------
    # Require AWS STS as the OIDC audience.
    # --------------------------------------------------------
    condition {

      test = "StringEquals"

      variable = (
        "token.actions.githubusercontent.com:aud"
      )

      values = [
        "sts.amazonaws.com",
      ]
    }


    # --------------------------------------------------------
    # Only jobs using the development-infrastructure GitHub
    # Environment may assume the Terraform deployment role.
    #
    # This also uses GitHub's immutable repository subject.
    # --------------------------------------------------------
    condition {

      test = "StringEquals"

      variable = (
        "token.actions.githubusercontent.com:sub"
      )

      values = [
        "repo:ridhampansara27@70193760/cloudops-infrastructure@1321840627:environment:development-infrastructure",
      ]
    }
  }
}


# Create the Terraform deployment role.
resource "aws_iam_role" "github_apply" {

  name = "cloudops-terraform-apply"

  assume_role_policy = (
    data.aws_iam_policy_document.github_apply_assume_role.json
  )
}


# ============================================================
# Terraform apply permissions
# ============================================================

data "aws_iam_policy_document" "github_apply_permissions" {


  # ----------------------------------------------------------
  # Terraform remote state bucket metadata
  # ----------------------------------------------------------
  statement {

    sid = "TerraformStateBucket"

    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.state_bucket_name}",
    ]
  }


  # ----------------------------------------------------------
  # Terraform state and native S3 lock file
  # ----------------------------------------------------------
  statement {

    sid = "TerraformStateObjects"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.state_bucket_name}/environments/dev/terraform.tfstate",
      "arn:aws:s3:::${var.state_bucket_name}/environments/dev/terraform.tfstate.tflock",
    ]
  }


  # ----------------------------------------------------------
  # Development AWS infrastructure
  # ----------------------------------------------------------
  #
  # The role is intentionally restricted to the AWS services
  # managed by the current CloudOps development Terraform stack.
  statement {

    sid = "ManageDevelopmentInfrastructure"

    effect = "Allow"

    actions = [
      "acm:*",
      "ec2:*",
      "eks:*",
      "secretsmanager:*",
    ]

    resources = [
      "*",
    ]


    # Prevent this development deployment role from changing
    # infrastructure in another AWS region.
    condition {

      test = "StringEquals"

      variable = "aws:RequestedRegion"

      values = [
        "eu-central-1",
      ]
    }
  }


  # ----------------------------------------------------------
  # Read IAM configuration
  # ----------------------------------------------------------
  statement {

    sid = "ReadIam"

    effect = "Allow"

    actions = [
      "iam:Get*",
      "iam:List*",
    ]

    resources = [
      "*",
    ]
  }


  # ----------------------------------------------------------
  # Manage only Terraform-owned CloudOps development IAM
  # roles and policies.
  #
  # This deliberately does NOT include:
  #
  #   cloudops-terraform-plan
  #   cloudops-terraform-apply
  #
  # Therefore the deployment role cannot modify its own
  # permissions or trust relationship.
  # ----------------------------------------------------------
  statement {

    sid = "ManageCloudOpsDevelopmentIam"

    effect = "Allow"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagPolicy",
      "iam:TagRole",
      "iam:UntagPolicy",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cloudops-dev-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/cloudops-dev-*",
    ]
  }


  # ----------------------------------------------------------
  # Allow AWS to create required service-linked roles.
  # ----------------------------------------------------------
  statement {

    sid = "CreateRequiredServiceLinkedRoles"

    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole",
    ]

    resources = [
      "*",
    ]

    condition {

      test = "StringEquals"

      variable = "iam:AWSServiceName"

      values = [
        "eks.amazonaws.com",
        "eks-nodegroup.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
      ]
    }
  }


  # ----------------------------------------------------------
  # Terraform uses STS to determine its active AWS identity.
  # ----------------------------------------------------------
  statement {

    sid = "ReadCallerIdentity"

    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity",
    ]

    resources = [
      "*",
    ]
  }
}


# Create the managed IAM policy used by Terraform Apply.
resource "aws_iam_policy" "github_apply" {

  name = "cloudops-terraform-apply"

  description = (
    "Permissions for approved GitHub Actions Terraform applies."
  )

  policy = (
    data.aws_iam_policy_document.github_apply_permissions.json
  )
}


# Attach the Terraform Apply permissions to the deployment role.
resource "aws_iam_role_policy_attachment" "github_apply" {

  role = aws_iam_role.github_apply.name

  policy_arn = aws_iam_policy.github_apply.arn
}


# ============================================================
# GitHub Actions Terraform plan role
# ============================================================

# Create the read-only Terraform planning role.
resource "aws_iam_role" "github_plan" {

  # Give the CI role a readable name.
  name = "cloudops-terraform-plan"

  # Trust only the constrained GitHub OIDC identity.
  assume_role_policy = (
    data.aws_iam_policy_document.github_plan_assume_role.json
  )
}


# Give Terraform read-only visibility into AWS resources.
resource "aws_iam_role_policy_attachment" "github_plan_readonly" {

  # Attach to the planning role.
  role = aws_iam_role.github_plan.name

  # Use AWS read-only access for provider refresh operations.
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}