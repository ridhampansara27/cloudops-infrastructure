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