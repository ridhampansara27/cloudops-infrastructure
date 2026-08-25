# ------------------------------------------------------------
# ACM certificate for the final CloudInsight hostname
# ------------------------------------------------------------

resource "aws_acm_certificate" "cloudinsight" {
  domain_name       = "cloudinsight.ridhampansara.dev"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project     = "cloudops-insight"
    Environment = "dev"
    ManagedBy   = "terraform"
    Temporary   = "true"
  }
}