# InnovateMart EKS Deployment Guide

## Project Overview
Production-grade Kubernetes deployment on AWS EKS with full CI/CD automation.

## Architecture
- **EKS Cluster**: innovatemart-eks (Kubernetes v1.28)
- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **Worker Nodes**: 2x t3.small EC2 instances
- **Application**: Retail Store Microservices

## Deployed Resources
- **Account ID**: 862287594288
- **Region**: us-east-1
- **S3 State Bucket**: innovatemart-tf-state-862287594288
- **Application URL**: http://a4a1dd2b0992c4913b025a736bc01858-826309835.us-east-1.elb.amazonaws.com

## Developer Access
Developer credentials available via Terraform outputs:
```bash
cd terraform
terraform output developer_access_key_id
terraform output developer_secret_access_key
```

## Deployment Instructions
See README.md for complete setup instructions.

## Cost Estimate
~$156/month for development environment
