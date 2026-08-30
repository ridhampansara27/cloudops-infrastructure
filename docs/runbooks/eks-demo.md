# Temporary EKS Demo Runbook

## Create

1. Verify AWS identity.
2. Verify Terraform state bucket.
3. Check public administrator IP.
4. terraform init.
5. terraform validate.
6. Trivy config scan.
7. terraform plan.
8. Review cost-impacting resources.
9. terraform apply.
10. aws eks update-kubeconfig.
11. Verify nodes.
12. Install Pod Identity Agent.
13. Install AWS Load Balancer Controller.
14. Install Argo CD.
15. Create runtime secret.
16. Apply cloudops-aws-dev Argo Application.
17. Wait for Synced / Healthy.
18. Verify ALB.
19. Verify Pod Identity.
20. Run CloudOps AWS synchronization.

## Destroy

1. Capture demonstration evidence.
2. Delete Kubernetes Ingress.
3. Wait until AWS ALB is deleted.
4. Delete CloudOps Argo Application.
5. Remove AWS Load Balancer Controller.
6. Remove Argo CD.
7. terraform plan -destroy.
8. Review destruction plan.
9. terraform apply destroy plan.
10. Verify EKS removed.
11. Verify EC2 removed.
12. Verify load balancers removed.
13. Verify NAT Gateways absent.
14. Verify CloudOps-tagged resources.
15. Check AWS Billing dashboard.