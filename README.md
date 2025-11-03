# InnovateMart EKS Deployment - Project Bedrock

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Deployed Infrastructure](#deployed-infrastructure)
- [Quick Start Guide](#quick-start-guide)
- [Developer Access Instructions](#developer-access-instructions)
- [CI/CD Pipeline](#cicd-pipeline)
- [Application Access](#application-access)
- [Project Structure](#project-structure)
- [Cost Estimate](#cost-estimate)
- [Cleanup](#cleanup)

---

## Overview

**Project Bedrock** is InnovateMart's inaugural production-grade Kubernetes deployment on AWS EKS. This project demonstrates Infrastructure as Code (IaC) best practices, automated CI/CD pipelines, and secure multi-tier application deployment.

### Key Features
- ✅ Production-ready EKS cluster with multi-AZ deployment
- ✅ Complete microservices architecture (6 services)
- ✅ Automated infrastructure deployment via Terraform
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Secure developer access with IAM and RBAC
- ✅ Comprehensive documentation and deployment guides

---

## Architecture

### High-Level Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Application Load    │
              │     Balancer         │
              └──────────┬───────────┘
                         │
        ┌────────────────┼────────────────┐
        │                                 │
┌───────▼────────┐              ┌────────▼────────┐
│   Public       │              │   Public        │
│   Subnet       │              │   Subnet        │
│   us-east-1a   │              │   us-east-1b    │
└───────┬────────┘              └────────┬────────┘
        │                                │
        │         NAT Gateway            │
        │                                │
┌───────▼────────┐              ┌────────▼────────┐
│   Private      │              │   Private       │
│   Subnet       │              │   Subnet        │
│   us-east-1a   │              │   us-east-1b    │
│                │              │                 │
│  ┌──────────┐  │              │  ┌──────────┐   │
│  │ EKS Node │  │              │  │ EKS Node │   │
│  │ t3.small │  │              │  │ t3.small │   │
│  └──────────┘  │              │  └──────────┘   │
└────────────────┘              └─────────────────┘
         │                               │
         └───────────┬───────────────────┘
                     │
         ┌───────────▼──────────────┐
         │   EKS Control Plane      │
         │   (Managed by AWS)       │
         └──────────────────────────┘
```

### Application Architecture
```
┌─────────────────────────────────────────────────────┐
│                    UI Service                       │
│              (Frontend - React)                     │
└──────┬──────────────────────────────────────────────┘
       │
       ├──────────────┬──────────────┬─────────────┐
       │              │              │             │
┌──────▼──────┐ ┌────▼──────┐ ┌────▼──────┐ ┌────▼──────┐
│  Catalog    │ │  Orders   │ │   Carts   │ │ Checkout  │
│  Service    │ │  Service  │ │  Service  │ │  Service  │
└──────┬──────┘ └────┬──────┘ └────┬──────┘ └────┬──────┘
       │             │              │             │
┌──────▼──────┐ ┌────▼──────┐ ┌────▼──────┐ ┌────▼──────┐
│   MySQL     │ │PostgreSQL │ │ DynamoDB  │ │  Redis    │
│             │ │ RabbitMQ  │ │  (local)  │ │           │
└─────────────┘ └───────────┘ └───────────┘ └───────────┘
```

---

## Prerequisites

Before deploying this project, ensure you have:

- **AWS Account** with administrative access
- **AWS CLI** (v2.x or later) installed and configured
- **Terraform** (v1.0 or later) installed
- **kubectl** (v1.28 or later) installed
- **Git** installed
- **GitHub Account** with repository access

---

## Deployed Infrastructure

### AWS Resources

| Resource Type | Name/ID | Configuration |
|--------------|---------|---------------|
| **EKS Cluster** | innovatemart-eks | Kubernetes v1.28 |
| **VPC** | vpc-0b6d08c226bba72a2 | 10.0.0.0/16 CIDR |
| **Public Subnets** | 2 subnets | 10.0.101.0/24, 10.0.102.0/24 |
| **Private Subnets** | 2 subnets | 10.0.1.0/24, 10.0.2.0/24 |
| **Worker Nodes** | 2 nodes | t3.small instances |
| **NAT Gateway** | 1 gateway | us-east-1a |
| **Internet Gateway** | 1 gateway | Attached to VPC |
| **S3 Bucket** | innovatemart-tf-state-862287594288 | Terraform state |
| **IAM User** | innovatemart-developer | Read-only access |
| **Account ID** | 862287594288 | us-east-1 region |

### Application Components

| Service | Type | Database | Status |
|---------|------|----------|--------|
| UI | Frontend | - | ✅ Running |
| Catalog | Microservice | MySQL | ✅ Running |
| Orders | Microservice | PostgreSQL + RabbitMQ | ✅ Running |
| Carts | Microservice | DynamoDB (local) | ✅ Running |
| Checkout | Microservice | Redis | ✅ Running |
| Assets | Static files | - | ✅ Running |

---

## Quick Start Guide

### Step 1: Clone Repository
```bash
git clone https://github.com/future-stacks/altschool_project2.git
cd altschool_project2
```

### Step 2: Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### Step 3: Initialize Terraform
```bash
cd terraform
terraform init
```

### Step 4: Review Infrastructure Plan
```bash
terraform plan
```

### Step 5: Deploy Infrastructure
```bash
terraform apply
# Type 'yes' when prompted
# Wait 15-20 minutes for completion
```

### Step 6: Configure kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name innovatemart-eks
```

### Step 7: Verify Cluster
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

### Step 8: Deploy Application
```bash
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml

# Wait for all pods to be ready
kubectl wait --for=condition=available --timeout=300s deployments --all
```

### Step 9: Get Application URL
```bash
kubectl get svc ui
# Copy the EXTERNAL-IP (LoadBalancer DNS)
```

---

## Developer Access Instructions

### Creating Read-Only Access for Developers

The project automatically creates an IAM user with read-only access to the EKS cluster.

### Step 1: Retrieve Developer Credentials

After `terraform apply` completes, get the credentials:
```bash
cd terraform

# Get Access Key ID
terraform output developer_access_key_id

# Get Secret Access Key (sensitive)
terraform output developer_secret_access_key
```

**Example output:**
```
developer_access_key_id = "AKIA4RRCYQMYJGAD4QFQ"
developer_secret_access_key = <sensitive>
```

### Step 2: Configure Developer's AWS CLI

Share these credentials with the developer securely (NOT via email or Slack).

Developer should run:
```bash
aws configure --profile innovatemart-dev
# AWS Access Key ID: [paste from terraform output]
# AWS Secret Access Key: [paste from terraform output]
# Default region: us-east-1
# Default output format: json
```

### Step 3: Configure kubectl for Developer
```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name innovatemart-eks \
  --profile innovatemart-dev
```

### Step 4: Verify Read-Only Access

Developer can run these commands:
```bash
# ✅ ALLOWED - View resources
kubectl get pods --all-namespaces
kubectl get services
kubectl get deployments
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# ❌ DENIED - Modify resources
kubectl delete pod <pod-name>        # This will fail
kubectl apply -f manifest.yaml       # This will fail
kubectl scale deployment --replicas=3 # This will fail
```

### Developer Permissions Summary

| Action | Allowed |
|--------|---------|
| View pods | ✅ Yes |
| View services | ✅ Yes |
| View deployments | ✅ Yes |
| Read logs | ✅ Yes |
| Describe resources | ✅ Yes |
| Create resources | ❌ No |
| Delete resources | ❌ No |
| Update resources | ❌ No |
| Execute commands in pods | ❌ No |

---

## CI/CD Pipeline

### GitHub Actions Workflow

The project uses GitHub Actions for automated Terraform deployments.

### Workflow Triggers

| Event | Branch | Action |
|-------|--------|--------|
| Pull Request | any → main | `terraform plan` (review only) |
| Push | main | `terraform apply` (auto-deploy) |
| Manual | main | Can be triggered from Actions tab |

### Workflow File Location

`.github/workflows/terraform-deploy.yml`

### Pipeline Stages
```
┌─────────────────┐
│  Code Push      │
│  to GitHub      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Checkout Code  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Configure AWS  │
│  Credentials    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Setup          │
│  Terraform      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Terraform Init │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Terraform Plan │
│  (on PR)        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Terraform Apply│
│  (on main)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Deployment     │
│  Complete ✅    │
└─────────────────┘
```

### Setting Up CI/CD

#### Step 1: Fork/Clone Repository

Repository is already set up at: https://github.com/future-stacks/altschool_project2

#### Step 2: Configure GitHub Secrets

Navigate to: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | For Terraform deployer user |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | For Terraform deployer user |

#### Step 3: Test the Pipeline

**Option A: Create a Pull Request**
```bash
git checkout -b feature/test-pipeline
echo "# Test" >> README.md
git add README.md
git commit -m "Test CI/CD pipeline"
git push origin feature/test-pipeline
```

Create PR on GitHub → Workflow runs `terraform plan`

**Option B: Push to Main**
```bash
git checkout main
echo "# Deploy" >> README.md
git add README.md
git commit -m "Deploy via CI/CD"
git push origin main
```

Workflow runs `terraform apply` automatically

#### Step 4: Monitor Workflow

Go to: https://github.com/future-stacks/altschool_project2/actions

View real-time logs and status of each run.

### Branching Strategy
```
main (production)
  │
  ├── feature/new-feature
  ├── feature/bug-fix
  └── feature/update-docs
```

- **main**: Production environment (auto-deploys on push)
- **feature/**: Development branches (runs plan on PR)
- **Pull Requests**: Required for merging to main

---

## Application Access

### Public URL

**Live Application**: http://a4a1dd2b0992c4913b025a736bc01858-826309835.us-east-1.elb.amazonaws.com

### Accessing the Application

1. Open the URL in your browser
2. You should see the InnovateMart Retail Store homepage
3. Browse products, add to cart, and test checkout flow

### Services Endpoints

| Service | Internal URL | External Access |
|---------|--------------|-----------------|
| UI | http://ui.default.svc.cluster.local | Via LoadBalancer |
| Catalog | http://catalog.default.svc.cluster.local:80 | Internal only |
| Orders | http://orders.default.svc.cluster.local:80 | Internal only |
| Carts | http://carts.default.svc.cluster.local:80 | Internal only |
| Checkout | http://checkout.default.svc.cluster.local:80 | Internal only |

---

## Project Structure
```
altschool_project2/
│
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml        # CI/CD pipeline configuration
│
├── terraform/
│   ├── main.tf                         # Provider and backend configuration
│   ├── variables.tf                    # Input variables
│   ├── vpc.tf                          # VPC, subnets, NAT gateway
│   ├── eks.tf                          # EKS cluster and node groups
│   ├── iam.tf                          # IAM users, roles, and RBAC
│   ├── outputs.tf                      # Output values
│   └── .terraform/                     # Terraform modules (gitignored)
│
├── kubernetes/
│   ├── manifests/                      # Custom Kubernetes manifests
│   ├── configmaps/                     # ConfigMap definitions
│   └── secrets/                        # Secret definitions (gitignored)
│
├── docs/
│   └── DEPLOYMENT_GUIDE.md             # Detailed deployment guide
│
├── scripts/
│   └── (deployment helper scripts)
│
├── .gitignore                          # Git ignore rules
└── README.md                           # This file
```

---

## Cost Estimate

### Monthly Cost Breakdown

| AWS Service | Configuration | Monthly Cost (USD) |
|-------------|---------------|-------------------|
| **EKS Control Plane** | 1 cluster | $73.00 |
| **EC2 Instances** | 2x t3.small (730 hrs) | $29.93 |
| **EBS Volumes** | 40 GB gp2 | $4.00 |
| **NAT Gateway** | 1 gateway + data transfer | $32.85 |
| **Application Load Balancer** | 1 ALB + LCU hours | $16.43 |
| **Data Transfer** | Outbound (estimated) | $5.00 |
| **S3 Storage** | Terraform state | $0.10 |
| **CloudWatch Logs** | EKS logs (estimated) | $3.00 |
| **Total** | | **~$164.31/month** |

### Cost Optimization Tips

- Use Spot Instances for non-production (save 60-90%)
- Stop cluster during non-business hours
- Use Fargate for variable workloads
- Enable cluster autoscaler for dynamic scaling
- Use Reserved Instances for 1-3 year commitment (save 30-60%)

---

## Cleanup

### ⚠️ Warning
This will destroy ALL resources and cannot be undone!

### Step 1: Delete Kubernetes Resources
```bash
kubectl delete -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
```

### Step 2: Wait for LoadBalancer Deletion
```bash
# Wait 2 minutes for AWS to cleanup LoadBalancer
sleep 120

# Verify LoadBalancer is gone
kubectl get svc
```

### Step 3: Destroy Terraform Infrastructure
```bash
cd terraform
terraform destroy
# Type 'yes' when prompted
# Wait 10-15 minutes
```

### Step 4: Delete S3 State Bucket (Optional)
```bash
aws s3 rb s3://innovatemart-tf-state-862287594288 --force
```

### Step 5: Delete IAM Access Keys
```bash
# In AWS Console: IAM → Users → terraform-deployer → Security credentials
# Delete all access keys
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Pods not starting
```bash
# Check pod status
kubectl get pods

# Describe pod for events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

#### Issue: Cannot connect to cluster
```bash
# Reconfigure kubectl
aws eks update-kubeconfig --region us-east-1 --name innovatemart-eks

# Verify AWS credentials
aws sts get-caller-identity

# Check cluster status
aws eks describe-cluster --name innovatemart-eks --region us-east-1
```

#### Issue: Terraform state locked
```bash
# List locks
aws s3api list-objects-v2 --bucket innovatemart-tf-state-862287594288 --prefix eks/

# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

#### Issue: CI/CD pipeline failing

- Check GitHub Secrets are set correctly
- Verify AWS credentials have proper permissions
- Review workflow logs in GitHub Actions tab
- Ensure no changes to protected resources outside Terraform

---

## Security Best Practices

### Implemented Security Measures

✅ **Infrastructure**
- Private subnets for worker nodes
- Security groups with minimal required ports
- Encrypted EBS volumes
- VPC flow logs enabled

✅ **Access Control**
- IAM least privilege principle
- Kubernetes RBAC for fine-grained permissions
- Read-only developer access
- No root access to containers

✅ **Secrets Management**
- Terraform state encrypted in S3
- AWS Secrets Manager for sensitive data
- GitHub Secrets for CI/CD credentials
- No hardcoded credentials in code

✅ **Compliance**
- CloudWatch logging enabled
- Audit logging for EKS API calls
- Version control for all infrastructure
- Change tracking via Git history

---

## Support and Contact

### For Issues or Questions

1. **Check Documentation**: Review this README and DEPLOYMENT_GUIDE.md
2. **Review Logs**: 
```bash
   kubectl logs <pod-name>
   kubectl describe pod <pod-name>
```
3. **Check Terraform State**:
```bash
   terraform state list
   terraform show
```
4. **AWS Console**: https://console.aws.amazon.com

### Useful Commands
```bash
# View all resources
kubectl get all --all-namespaces

# Check cluster health
kubectl get componentstatuses

# View resource usage
kubectl top nodes
kubectl top pods

# Terraform commands
terraform plan        # Preview changes
terraform apply       # Apply changes
terraform destroy     # Destroy infrastructure
terraform output      # View outputs
terraform state list  # List resources
```

---

## License

This project is part of AltSchool Africa Cloud Engineering assessment.

---

## Acknowledgments

- **AWS**: For EKS and cloud infrastructure
- **Terraform**: For Infrastructure as Code
- **Kubernetes**: For container orchestration
- **AltSchool Africa**: For the project requirements

---

**Project Bedrock - InnovateMart Inc.**  
*Deployed: October 2025*  
*Maintained by: Cloud DevOps Team*
