# Configure Oracle Cloud Infrastructure.
provider "oci" {

  # Use the region selected for the CloudOps OCI environment.
  region = var.oci_region

  # Reuse the local OCI CLI/API-key profile.
  #
  # Credentials remain in ~/.oci/config and are NOT stored
  # inside the Terraform repository.
  config_file_profile = var.oci_profile
}
