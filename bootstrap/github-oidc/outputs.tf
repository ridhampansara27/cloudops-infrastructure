# GitHub Actions OIDC provider ARN.
output "github_oidc_provider_arn" {

  description = "ARN of the GitHub Actions AWS OIDC provider."

  value = (
    aws_iam_openid_connect_provider.github.arn
  )
}


# Role used by Terraform pull-request plans.
output "terraform_plan_role_arn" {

  description = "IAM role ARN used by Terraform PR plans."

  value = (
    aws_iam_role.github_plan.arn
  )
}


# Role used by approved Terraform applies.
output "terraform_apply_role_arn" {

  description = "IAM role ARN used by approved Terraform applies."

  value = (
    aws_iam_role.github_apply.arn
  )
}