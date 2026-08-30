# Return EKS cluster name.
output "cluster_name" {

  value = module.eks.cluster_name
}


# Return EKS API endpoint.
output "cluster_endpoint" {

  value = module.eks.cluster_endpoint
}


# Return VPC ID.
output "vpc_id" {

  value = module.network.vpc_id
}


# Return worker subnet IDs.
output "public_subnet_ids" {

  value = module.network.public_subnet_ids
}