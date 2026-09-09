# Define Terraform compatibility.
terraform {

  # Match the minimum Terraform version already used by this repository.
  required_version = ">= 1.11.0"

  # Declare providers used by the OCI environment.
  required_providers {

    oci = {

      # Use Oracle's official OCI Terraform provider.
      source = "oracle/oci"

      # Stay within OCI Provider major version 8.
      version = "~> 8.29"
    }
  }
}
