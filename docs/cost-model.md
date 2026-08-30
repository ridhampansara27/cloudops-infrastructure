# AWS Cost Model

## Always-on cost drivers

### EKS control plane
Charged per cluster-hour.

### Managed worker nodes
EC2 instance runtime + EBS + IPv4 usage.

### Application Load Balancer
Hourly ALB charge + LCU usage + public IPv4.

### NAT Gateway
Hourly charge + data processing.

### RDS
DB instance + storage + backup usage.

### ElastiCache
Cache node/serverless usage.


## Portfolio strategy

The demonstration environment intentionally avoids:
- NAT Gateway
- Permanent RDS
- Permanent ElastiCache
- Permanent EKS

Workflow:

terraform apply
↓
run demo
↓
capture screenshots
↓
delete Kubernetes ALB
↓
terraform destroy


## Production trade-off

The cheapest architecture is not automatically the best production
architecture.

Production recommendations include:
- private workloads,
- managed databases,
- managed cache,
- high availability,
- TLS,
- centralized secrets,
- stronger network isolation.