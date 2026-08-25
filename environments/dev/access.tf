# ------------------------------------------------------------
# Explicit EKS administrator access
# ------------------------------------------------------------

# Create a modern EKS access entry for the administrator principal.
resource "aws_eks_access_entry" "administrator" {

  # Attach the access entry to the CloudOps cluster.
  cluster_name = module.eks.cluster_name

  # Grant access to the explicitly configured IAM principal.
  principal_arn = var.eks_admin_principal_arn

  # Use a normal human/operator access entry.
  type = "STANDARD"
}


# Associate cluster-admin Kubernetes permissions.
resource "aws_eks_access_policy_association" "administrator" {

  # Attach the access policy to the same EKS cluster.
  cluster_name = module.eks.cluster_name

  # Match the principal from the access entry.
  principal_arn = aws_eks_access_entry.administrator.principal_arn

  # Use AWS' EKS-managed cluster administrator policy.
  policy_arn = (
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  )

  # Grant the policy across the entire cluster.
  access_scope {

    # Apply access at cluster scope.
    type = "cluster"
  }
}