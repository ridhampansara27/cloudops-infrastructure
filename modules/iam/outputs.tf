# Return EKS cluster service role ARN.
output "cluster_role_arn" {

  value = aws_iam_role.eks_cluster.arn
}


# Return EKS worker node role ARN.
output "node_role_arn" {

  value = aws_iam_role.eks_node.arn
}