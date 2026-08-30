# Return cluster name.
output "cluster_name" {

  value = aws_eks_cluster.this.name
}


# Return EKS API endpoint.
output "cluster_endpoint" {

  value = aws_eks_cluster.this.endpoint
}


# Return EKS certificate authority information.
output "cluster_certificate_authority_data" {

  value = (
    aws_eks_cluster.this.certificate_authority[0].data
  )

  sensitive = true
}


# Return worker node-group name.
output "node_group_name" {

  value = aws_eks_node_group.default.node_group_name
}