# CloudOps AWS Networking Cost Strategy

## Development / portfolio environment

Architecture:

Internet Gateway
↓
Public EKS worker nodes

No NAT Gateway.

Reason:
- Short-lived environment.
- Lower fixed AWS networking cost.
- Easy destroy/recreate workflow.


## Production target

Architecture:

Internet
↓
ALB in public subnets
↓
EKS workers in private subnets
↓
RDS / ElastiCache in isolated private subnets


## NAT Gateway

Advantages:
- General outbound internet connectivity.
- Required when private workloads need arbitrary external services.
- Simple application behavior.

Disadvantages:
- Hourly charge.
- Per-GB processing charge.
- Additional cost if deployed per Availability Zone.


## VPC Endpoints

S3 and DynamoDB gateway endpoints:
- No additional endpoint charge.
- No NAT required for those services.

Interface endpoints:
- Private access to supported AWS services.
- Hourly endpoint charge.
- Per-GB processing charge.


## CloudOps-specific consideration

CloudOps currently pulls application images from GHCR.

Private EKS nodes cannot pull GHCR through AWS VPC endpoints because
GHCR is an external service.

Production choices:

1. NAT Gateway + GHCR.
2. Mirror application images into Amazon ECR.
3. Use ECR VPC endpoints plus S3 gateway endpoint.