output "cluster_id" {
  description = "OCID of the OKE cluster."
  value       = oci_containerengine_cluster.this.id
}

output "cluster_name" {
  description = "Name of the OKE cluster."
  value       = oci_containerengine_cluster.this.name
}

output "cluster_state" {
  description = "Lifecycle state of the OKE cluster."
  value       = oci_containerengine_cluster.this.state
}

output "kubernetes_version" {
  description = "Kubernetes version of the OKE cluster."
  value       = oci_containerengine_cluster.this.kubernetes_version
}
