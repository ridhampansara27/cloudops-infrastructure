# ------------------------------------------------------------
# EKS control-plane role
# ------------------------------------------------------------

data "aws_iam_policy_document" "eks_cluster_assume_role" {

  statement {

    effect = "Allow"

    principals {

      type = "Service"

      identifiers = [
        "eks.amazonaws.com",
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}


resource "aws_iam_role" "eks_cluster" {

  name = (
    "${var.project_name}-${var.environment}-eks-cluster-role"
  )

  assume_role_policy = (
    data.aws_iam_policy_document.eks_cluster_assume_role.json
  )
}


resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_cluster.name

  policy_arn = (
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  )
}


# ------------------------------------------------------------
# EKS managed-node role
# ------------------------------------------------------------

data "aws_iam_policy_document" "eks_node_assume_role" {

  statement {

    effect = "Allow"

    principals {

      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}


resource "aws_iam_role" "eks_node" {

  name = (
    "${var.project_name}-${var.environment}-eks-node-role"
  )

  assume_role_policy = (
    data.aws_iam_policy_document.eks_node_assume_role.json
  )
}


# Allow EKS worker nodes to operate as Kubernetes nodes.
resource "aws_iam_role_policy_attachment" "worker_node" {

  role = aws_iam_role.eks_node.name

  policy_arn = (
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  )
}


# Allow worker nodes to obtain networking configuration.
resource "aws_iam_role_policy_attachment" "cni" {

  role = aws_iam_role.eks_node.name

  policy_arn = (
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  )
}


# Allow worker nodes to pull container images from Amazon ECR.
resource "aws_iam_role_policy_attachment" "ecr" {

  role = aws_iam_role.eks_node.name

  policy_arn = (
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  )
}


# ------------------------------------------------------------
# Generic EKS Pod Identity trust relationship
# ------------------------------------------------------------

data "aws_iam_policy_document" "pod_identity_assume_role" {

  statement {

    # Give the trust statement a readable identifier.
    sid = "AllowEksPodIdentity"

    # Permit the EKS Pod Identity service.
    effect = "Allow"

    principals {

      # Trust an AWS service principal.
      type = "Service"

      # Trust the EKS Pod Identity service.
      identifiers = [
        "pods.eks.amazonaws.com",
      ]
    }

    # Allow EKS to assume and tag workload sessions.
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
  }
}


# ------------------------------------------------------------
# CloudOps application workload role
# ------------------------------------------------------------

resource "aws_iam_role" "cloudops_workload" {

  # Create a predictable IAM role name.
  name = (
    "${var.project_name}-${var.environment}-cloudops-workload-role"
  )

  # Allow EKS Pod Identity to assume this role.
  assume_role_policy = (
    data.aws_iam_policy_document.pod_identity_assume_role.json
  )
}


data "aws_iam_policy_document" "cloudops_workload" {

  statement {

    # Identify application discovery permissions.
    sid = "CloudOpsAwsReadAccess"

    # Allow read-only AWS operations.
    effect = "Allow"

    # Grant only APIs used by the CloudOps application.
    actions = [
      "ec2:DescribeInstances",
      "rds:DescribeDBInstances",
      "rds:ListTagsForResource",
      "ecs:ListClusters",
      "ecs:DescribeClusters",
      "ecs:ListServices",
      "ecs:DescribeServices",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTags",
      "s3:ListAllMyBuckets",
      "s3:GetBucketTagging",
      "cloudwatch:GetMetricData",
      "ce:GetCostAndUsage",
      "ce:GetCostAndUsageWithResources",
      "sts:GetCallerIdentity",
    ]

    # These discovery APIs require broad resource scope.
    resources = [
      "*",
    ]
  }
}


resource "aws_iam_policy" "cloudops_workload" {

  # Give the policy a readable name.
  name = (
    "${var.project_name}-${var.environment}-cloudops-workload"
  )

  # Attach the generated least-privilege policy document.
  policy = (
    data.aws_iam_policy_document.cloudops_workload.json
  )
}


resource "aws_iam_role_policy_attachment" "cloudops_workload" {

  # Attach permissions to the workload role.
  role = aws_iam_role.cloudops_workload.name

  # Use the CloudOps application policy.
  policy_arn = aws_iam_policy.cloudops_workload.arn
}


# ------------------------------------------------------------
# AWS Load Balancer Controller role
# ------------------------------------------------------------

resource "aws_iam_role" "load_balancer_controller" {

  # Create the controller IAM role.
  name = (
    "${var.project_name}-${var.environment}-load-balancer-controller-role"
  )

  # Allow EKS Pod Identity to assume this role.
  assume_role_policy = (
    data.aws_iam_policy_document.pod_identity_assume_role.json
  )
}


resource "aws_iam_policy" "load_balancer_controller" {

  # Create a project-specific copy of the official controller policy.
  name = (
    "${var.project_name}-${var.environment}-load-balancer-controller"
  )

  # Load the AWS Load Balancer Controller policy pinned in the repository.
  policy = file(
    "${path.module}/policies/aws-load-balancer-controller-v2.14.1.json"
  )
}


resource "aws_iam_role_policy_attachment" "load_balancer_controller" {

  # Attach the controller policy to its role.
  role = aws_iam_role.load_balancer_controller.name

  # Attach the official controller IAM permissions.
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}