# ============================================================
# OCI remote Terraform state
# ============================================================
#
# The Object Storage bucket is intentionally provisioned as a
# bootstrap resource outside this Terraform state. This avoids
# making the backend depend on the state that it stores.

terraform {
  backend "oci" {
    bucket              = "cloudops-insight-terraform-state"
    namespace           = "frhrqmkibkyi"
    key                 = "cloudops-insight/oci-dev/terraform.tfstate"
    region              = "eu-frankfurt-1"
    auth                = "APIKey"
    config_file_profile = "CLOUDOPS"
  }
}