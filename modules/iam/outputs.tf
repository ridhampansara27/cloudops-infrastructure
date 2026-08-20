# Return EKS cluster service role ARN.
output "cluster_role_arn" {

  value = aws_iam_role.eks_cluster.arn
}


# Return EKS worker node role ARN.
output "node_role_arn" {

  value = aws_iam_role.eks_node.arn
}


# Return the IAM role used by CloudOps application Pods.
output "cloudops_workload_role_arn" {

  # Expose workload role ARN to the environment root.
  value = aws_iam_role.cloudops_workload.arn
}


# Return the AWS Load Balancer Controller role ARN.
output "load_balancer_controller_role_arn" {

  # Expose controller role ARN.
  value = aws_iam_role.load_balancer_controller.arn
}