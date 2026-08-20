# ------------------------------------------------------------
# EKS control plane
# ------------------------------------------------------------

resource "aws_eks_cluster" "this" {

  # Give the cluster a deterministic name.
  name = var.cluster_name

  # Use the selected supported Kubernetes version.
  version = var.kubernetes_version

  # Export all EKS control-plane log types to CloudWatch Logs.
  # These logs provide API, audit, authentication, controller,
  # and scheduler visibility for security and troubleshooting.
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  # Allow the EKS control plane to call AWS APIs.
  role_arn = var.cluster_role_arn

  # Use modern EKS API-based access management.
  access_config {

    # Store Kubernetes access through EKS access entries.
    authentication_mode = "API"

    # Keep initial creator access for the bootstrap phase.
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {

    # Attach the EKS control plane to the configured subnets.
    subnet_ids = var.subnet_ids

    # Allow Kubernetes API access from inside the VPC.
    endpoint_private_access = true

    # Also allow administrator access from the configured public IP.
    endpoint_public_access = true

    # Restrict public control-plane access to explicit CIDRs.
    public_access_cidrs = (
      var.endpoint_public_access_cidrs
    )
  }
}



# ------------------------------------------------------------
# EKS managed worker nodes
# ------------------------------------------------------------

resource "aws_eks_node_group" "default" {

  # Attach nodes to this EKS cluster.
  cluster_name = aws_eks_cluster.this.name

  # Give the node group a readable name.
  node_group_name = "general"

  # IAM role used by worker EC2 instances.
  node_role_arn = var.node_role_arn

  # Launch nodes across configured subnets.
  subnet_ids = var.subnet_ids

  # Use x86 Amazon Linux 2023 optimized for EKS.
  ami_type = "AL2023_x86_64_STANDARD"

  # Use On-Demand initially for predictable demo behavior.
  capacity_type = "ON_DEMAND"

  # Use the configured EC2 size.
  instance_types = var.node_instance_types

  # Keep the demo cluster intentionally small.
  scaling_config {

    # Minimum worker capacity.
    min_size = 1

    # Normal demo worker count.
    desired_size = 1

    # Permit limited scaling for testing.
    max_size = 2
  }

  update_config {

    # Replace only one node at a time.
    max_unavailable = 1
  }

  # Protect against Terraform fighting future autoscaling changes.
  lifecycle {

    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }
}