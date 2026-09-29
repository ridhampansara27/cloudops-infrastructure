# Security policy

Report vulnerabilities privately through GitHub private vulnerability reporting when available or contact the maintainer privately. Do not disclose OCI tenancy identifiers together with credentials, Terraform state, plan files, real administrator IP ranges, backup artifacts, or Sealed Secrets key material.

OCI authentication currently uses an operator workstation profile. PR CI is credential-free and does not prove live OCI drift. Review cloud-connected plans separately. The public Kubernetes API is restricted by NSG and configured CIDR; application ingress uses Cloudflare Tunnel. Kubernetes NetworkPolicy is disabled with Flannel Overlay in the current GitOps values.
