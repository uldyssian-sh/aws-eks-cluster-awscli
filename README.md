# AWS EKS Cluster with AWS CLI

<div align="center">

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS EKS Architecture                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │     VPC     │────│ EKS Control │────│   Worker    │     │
│  │  Subnets    │    │    Plane    │    │   Nodes     │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         │                   │                   │          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ Load        │    │ Auto        │    │ Container   │     │
│  │ Balancer    │    │ Scaling     │    │ Registry    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```
  
  [![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4.svg)](https://www.terraform.io/)
  [![AWS EKS](https://img.shields.io/badge/AWS-EKS-FF9900.svg)](https://aws.amazon.com/eks/)
  [![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5.svg)](https://kubernetes.io/)
</div>

## 🚀 Overview

Production-ready AWS EKS cluster deployment using AWS CLI and Terraform. Includes monitoring, logging, and security best practices.

## ⚡ Quick Start

```bash
# Clone repository
git clone https://github.com/uldyssian-sh/aws-eks-cluster-awscli.git
cd aws-eks-cluster-awscli

# Configure AWS credentials
aws configure

# Initialize and deploy
terraform init
terraform plan -var="cluster_name=my-eks-cluster"
terraform apply

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster
```

## 📚 Documentation

- [Deployment Guide](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/wiki/Deployment)
- [Monitoring Setup](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/wiki/Monitoring)
- [Security Hardening](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/wiki/Security)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
