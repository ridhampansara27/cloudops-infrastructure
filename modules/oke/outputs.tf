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

output "node_pool_id" {
  description = "OCID of the ARM64 OKE managed node pool."
  value       = oci_containerengine_node_pool.arm.id
}

output "node_pool_name" {
  description = "Name of the ARM64 OKE managed node pool."
  value       = oci_containerengine_node_pool.arm.name
}

output "node_pool_state" {
  description = "Lifecycle state of the ARM64 OKE managed node pool."
  value       = oci_containerengine_node_pool.arm.state
}

output "selected_worker_image_name" {
  description = "Automatically selected ARM64 Oracle Linux OKE worker image."
  value       = local.selected_arm_oke_source_name
}
