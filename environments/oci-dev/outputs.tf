output "oci_region" {

  description = "OCI region used by this environment."
  value       = var.oci_region
}


output "availability_domains" {

  description = "Availability Domains available in the OCI region."

  value = [
    for ad in data.oci_identity_availability_domains.current.availability_domains :
    ad.name
  ]
}


output "compartment_name" {

  description = "Dedicated OCI compartment used by CloudOps."
  value       = oci_identity_compartment.cloudops.name
}


output "vcn_id" {

  description = "OCI VCN OCID."
  value       = module.oci_network.vcn_id
}


output "api_subnet_id" {

  description = "OKE API subnet OCID."
  value       = module.oci_network.api_subnet_id
}


output "worker_subnet_id" {

  description = "OKE worker subnet OCID."
  value       = module.oci_network.worker_subnet_id
}

output "oke_cluster_name" {
  description = "Name of the OCI OKE cluster."
  value       = module.oke.cluster_name
}

output "oke_cluster_id" {
  description = "OCID of the OCI OKE cluster."
  value       = module.oke.cluster_id
}

output "oke_cluster_state" {
  description = "Lifecycle state of the OCI OKE cluster."
  value       = module.oke.cluster_state
}
