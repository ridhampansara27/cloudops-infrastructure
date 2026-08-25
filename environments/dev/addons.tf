# ------------------------------------------------------------
# EKS Pod Identity Agent
# ------------------------------------------------------------

resource "aws_eks_addon" "pod_identity_agent" {

  # Install the add-on on the CloudOps EKS cluster.
  cluster_name = module.eks.cluster_name

  # Use the AWS-managed Pod Identity Agent.
  addon_name = "eks-pod-identity-agent"

  # Allow AWS to select a compatible current add-on version.
  resolve_conflicts_on_update = "PRESERVE"
}


# ------------------------------------------------------------
# CloudOps application Pod Identity
# ------------------------------------------------------------

resource "aws_eks_pod_identity_association" "cloudops" {

  # Associate identity with this EKS cluster.
  cluster_name = module.eks.cluster_name

  # CloudOps workloads run in this namespace.
  namespace = "cloudops"

  # Backend and worker will use this ServiceAccount.
  service_account = "cloudops-aws"

  # Supply the IAM role containing CloudOps read permissions.
  role_arn = module.iam.cloudops_workload_role_arn

  # Ensure the Pod Identity Agent exists first.
  depends_on = [
    aws_eks_addon.pod_identity_agent,
  ]
}


# ------------------------------------------------------------
# AWS Load Balancer Controller Pod Identity
# ------------------------------------------------------------

resource "aws_eks_pod_identity_association" "load_balancer_controller" {

  # Associate identity with this EKS cluster.
  cluster_name = module.eks.cluster_name

  # AWS Load Balancer Controller runs in kube-system.
  namespace = "kube-system"

  # Match the Helm controller ServiceAccount.
  service_account = "aws-load-balancer-controller"

  # Supply the controller IAM role.
  role_arn = module.iam.load_balancer_controller_role_arn

  # Require the Pod Identity Agent first.
  depends_on = [
    aws_eks_addon.pod_identity_agent,
  ]
}


# ------------------------------------------------------------
# Amazon VPC CNI
# ------------------------------------------------------------

resource "aws_eks_addon" "vpc_cni" {

  # Install into the CloudOps EKS cluster.
  cluster_name = module.eks.cluster_name

  # Manage the AWS VPC networking plugin through EKS.
  addon_name = "vpc-cni"

  # Adopt/overwrite the bootstrap self-managed installation.
  resolve_conflicts_on_create = "OVERWRITE"

  # Preserve intentional configuration during future upgrades.
  resolve_conflicts_on_update = "PRESERVE"
}


# ------------------------------------------------------------
# CoreDNS
# ------------------------------------------------------------

resource "aws_eks_addon" "coredns" {

  # Install into the CloudOps cluster.
  cluster_name = module.eks.cluster_name

  # Manage Kubernetes DNS through the EKS Add-ons API.
  addon_name = "coredns"

  # Replace the automatically-created self-managed installation.
  resolve_conflicts_on_create = "OVERWRITE"

  # Preserve future explicit configuration.
  resolve_conflicts_on_update = "PRESERVE"

  # CoreDNS requires compute to exist before it can become healthy.
  depends_on = [
    module.eks,
  ]
}


# ------------------------------------------------------------
# kube-proxy
# ------------------------------------------------------------

resource "aws_eks_addon" "kube_proxy" {

  # Install into the CloudOps cluster.
  cluster_name = module.eks.cluster_name

  # Manage kube-proxy through EKS.
  addon_name = "kube-proxy"

  # Adopt the existing cluster installation.
  resolve_conflicts_on_create = "OVERWRITE"

  # Avoid unexpectedly replacing custom values.
  resolve_conflicts_on_update = "PRESERVE"
}