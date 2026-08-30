## PostgreSQL

Development / local:
- PostgreSQL StatefulSet inside Kubernetes.

Production target:
- Amazon RDS for PostgreSQL.
- Private DB subnet group.
- Storage encryption.
- TLS connections.
- No public endpoint.
- Security-group access only from EKS.
- RDS-managed master password in Secrets Manager.
- Multi-AZ enabled in production.


## Redis

Development / local:
- Redis Deployment inside Kubernetes.

Production target:
- Amazon ElastiCache for Valkey.
- Private cache subnet group.
- Encryption at rest.
- TLS encryption in transit.
- Authentication enabled.
- No public access.
- Access restricted to EKS workloads.


## Deployment policy

RDS and ElastiCache are not permanently provisioned for the
portfolio/demo environment because they introduce additional recurring cost.

Terraform modules document the intended production architecture,
while the low-cost dev environment continues to use in-cluster
PostgreSQL and Redis.