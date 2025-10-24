#InnovateMart EKS Deployment

Production-grade Kubernetes deployment on AWS EKS with full automation.

## Architecture

Internet
    ↓
[Route53] → [ALB + ACM Certificate]
    ↓
[EKS Cluster]
    ├── Public Subnets (2 AZs) - Load Balancers
    └── Private Subnets (2 AZs) - Worker Nodes
        ├── UI Service
        ├── Catalog Service → RDS MySQL
        ├── Orders Service → RDS PostgreSQL
        ├── Carts Service → DynamoDB
        ├── Checkout Service
        └── Assets Service

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl
- Helm 3

## Quick Start

1. Clone repository:
   \`\`\`bash
   git clone 
   cd innovatemart-eks
   \`\`\`

2. Configure Terraform backend:
   \`\`\`bash
   aws s3 mb s3://innovatemart-terraform-state
   \`\`\`

3. Deploy infrastructure:
   \`\`\`bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   \`\`\`

4. Configure kubectl:
   \`\`\`bash
   aws eks update-kubeconfig --region us-east-1 --name innovatemart-eks
   \`\`\`

5. Deploy application:
   \`\`\`bash
   ./scripts/deploy-app.sh
   \`\`\`

## Developer Access

Credentials for read-only user:
- Access Key ID: (output from terraform)
- Secret Access Key: (output from terraform)

Setup instructions:
\`\`\`bash
./scripts/setup-kubeconfig.sh
kubectl get pods --all-namespaces
\`\`\`

## Application URL

- HTTP: http://
- HTTPS: https://shop.innovatemart.example.com

## CI/CD

Push to `main` branch triggers automatic deployment.
Pull requests run `terraform plan` for review.

## Cleaning Up

\`\`\`bash
terraform destroy
\`\`\`
```
