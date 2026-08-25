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

  # Install Metrics Server in the existing development cluster.
  cluster_name = "cloudops-dev"

  # AWS community add-on name.
  addon_name = "metrics-server"

  # Pin the EKS-compatible version returned by AWS.
  addon_version = "v0.9.0-eksbuild.6"

  # Allow EKS to manage conflicting default objects.
  resolve_conflicts_on_create = "OVERWRITE"

  # Preserve intentional configuration during future updates.
  resolve_conflicts_on_update = "PRESERVE"
}