# ------------------------------------------------------------
# Local configuration
# ------------------------------------------------------------

locals {

  # Build one consistent EKS cluster name.
  cluster_name = (
    "${var.project_name}-${var.environment}"
  )

  # Use two Frankfurt Availability Zones.
  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b",
  ]
}


# ------------------------------------------------------------
# Networking
# ------------------------------------------------------------

module "network" {

  # Use the reusable networking module.
  source = "../../modules/network"

  # Supply project name.
  project_name = var.project_name

  # Supply environment.
  environment = var.environment

  # Create the VPC across two AZs.
  availability_zones = (
    local.availability_zones
  )
}


# ------------------------------------------------------------
# IAM
# ------------------------------------------------------------

module "iam" {

  # Use reusable EKS IAM configuration.
  source = "../../modules/iam"

  project_name = var.project_name

  environment = var.environment
}


# ------------------------------------------------------------
# EKS
# ------------------------------------------------------------

module "eks" {

  # Use reusable EKS module.
  source = "../../modules/eks"

  # Configure cluster name.
  cluster_name = local.cluster_name

  # Configure Kubernetes version.
  kubernetes_version = (
    var.kubernetes_version
  )

  # Run EKS in the cost-optimized public subnets.
  subnet_ids = (
    module.network.public_subnet_ids
  )

  # Supply control-plane IAM role.
  cluster_role_arn = (
    module.iam.cluster_role_arn
  )

  # Supply worker-node IAM role.
  node_role_arn = (
    module.iam.node_role_arn
  )

  # Restrict the public Kubernetes API endpoint.
  endpoint_public_access_cidrs = (
    var.cluster_endpoint_public_access_cidrs
  )

  # Supply worker node sizes.
  node_instance_types = (
    var.node_instance_types
  )

  # Ensure IAM policies exist before EKS creation begins.
  depends_on = [
    module.iam,
  ]
}


# ------------------------------------------------------------
# Secrets Manager
# ------------------------------------------------------------

module "secrets" {

  # Use reusable Secrets Manager resources.
  source = "../../modules/secrets"

  # Supply project name.
  project_name = var.project_name

  # Supply environment.
  environment = var.environment
}