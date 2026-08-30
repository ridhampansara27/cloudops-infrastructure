# CloudOps Insight Infrastructure Architecture

## Portfolio / Development Architecture

```mermaid
flowchart TD
    User[Browser] --> ALB[AWS Application Load Balancer]
    ALB --> EKS[Amazon EKS]

    EKS --> Frontend[React / NGINX]
    EKS --> Backend[FastAPI]
    EKS --> Worker[Celery Worker]
    EKS --> Beat[Celery Beat]

    Backend --> PostgreSQL[(PostgreSQL in Kubernetes)]
    Backend --> Redis[(Redis in Kubernetes)]

    Worker --> AWS[AWS APIs]
    AWS --> CW[CloudWatch]
    AWS --> CE[Cost Explorer]

    Argo[Argo CD] --> EKS
    GitOps[cloudops-gitops] --> Argo