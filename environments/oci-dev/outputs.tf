# Display the configured OCI region.
output "oci_region" {

  description = "OCI region used by this environment."
  value       = var.oci_region
}


# Display the Availability Domain names discovered from OCI.
output "availability_domains" {

  description = "Availability Domains available in the OCI region."

  value = [
    for ad in data.oci_identity_availability_domains.current.availability_domains :
    ad.name
  ]
}
