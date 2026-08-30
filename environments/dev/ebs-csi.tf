# ------------------------------------------------------------
# AWS EBS CSI Driver
# ------------------------------------------------------------
#
# PostgreSQL uses a PersistentVolumeClaim in EKS.
# The EBS CSI driver dynamically provisions the required
# Amazon EBS volume.
#
# Authentication uses EKS Pod Identity rather than IRSA.


# ------------------------------------------------------------
# Pod Identity trust policy
# ------------------------------------------------------------

data "aws_iam_policy_document" "ebs_csi_pod_identity_assume_role" {

  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {

      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com",
      ]
    }
  }
}


# ------------------------------------------------------------
# IAM role used by the EBS CSI controller
# ------------------------------------------------------------

resource "aws_iam_role" "ebs_csi" {

  name = "cloudops-dev-ebs-csi-role"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_pod_identity_assume_role.json
}


# ------------------------------------------------------------
# Attach AWS-managed EBS CSI permissions
# ------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ebs_csi" {

  role = aws_iam_role.ebs_csi.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"
}


# ------------------------------------------------------------
# Install the EBS CSI EKS managed add-on
# ------------------------------------------------------------

resource "aws_eks_addon" "ebs_csi" {

  cluster_name = "cloudops-dev"

  addon_name = "aws-ebs-csi-driver"

  # Pin the EKS-compatible version returned by AWS.
  addon_version = "v1.64.0-eksbuild.1"

  # Handle any existing Kubernetes objects created by EKS.
  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "PRESERVE"


  # ----------------------------------------------------------
  # EKS Pod Identity
  # ----------------------------------------------------------
  #
  # AWS EBS CSI controller runs under this ServiceAccount.
  # EKS injects credentials for the IAM role above.

  pod_identity_association {

    service_account = "ebs-csi-controller-sa"

    role_arn = aws_iam_role.ebs_csi.arn
  }


  # Pod Identity agent must already be available.
  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.ebs_csi,
  ]
}