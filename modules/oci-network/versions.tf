# Define provider requirements for the OCI network module.
terraform {

  required_providers {

    oci = {

      # OCI provider is maintained by Oracle.
      source = "oracle/oci"

      # Keep the module aligned with the OCI environment.
      version = "~> 8.29"
    }
  }
}
