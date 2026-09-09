output "vcn_id" {

  description = "OCID of the CloudOps OCI VCN."
  value       = oci_core_vcn.this.id
}


output "api_subnet_id" {

  description = "OCID of the OKE API endpoint subnet."
  value       = oci_core_subnet.api.id
}


output "worker_subnet_id" {

  description = "OCID of the OKE worker subnet."
  value       = oci_core_subnet.workers.id
}


output "api_nsg_id" {

  description = "OCID of the OKE API Network Security Group."
  value       = oci_core_network_security_group.api.id
}


output "worker_nsg_id" {

  description = "OCID of the OKE worker Network Security Group."
  value       = oci_core_network_security_group.workers.id
}


output "public_route_table_id" {

  description = "OCID of the public OCI route table."
  value       = oci_core_route_table.public.id
}
