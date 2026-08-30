# ------------------------------------------------------------
# Kubernetes Metrics Server
# ------------------------------------------------------------
#
# Metrics Server exposes CPU and memory usage through the
# Kubernetes resource metrics API.
#
# The HorizontalPodAutoscaler uses this API to determine
# whether backend replicas should scale up or down.


resource "aws_eks_addon" "metrics_server" {

  # Use the same cluster name constructed by the environment.
  cluster_name = local.cluster_name

  # AWS community add-on name.
  addon_name = "metrics-server"

  # Pin the EKS-compatible version returned by AWS.
  addon_version = "v0.9.0-eksbuild.6"

  # Allow EKS to resolve conflicts with objects that may already
  # exist when the managed add-on is initially installed.
  resolve_conflicts_on_create = "OVERWRITE"

  # Preserve intentional configuration during later updates.
  resolve_conflicts_on_update = "PRESERVE"

  # local.cluster_name is only a string and does not itself create
  # a dependency on module.eks. Explicitly wait until the EKS
  # cluster has been provisioned before creating this add-on.
  depends_on = [
    module.eks,
  ]
}