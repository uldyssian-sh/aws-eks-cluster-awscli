# AWS EKS Cluster AWSCLI

[![GitHub license](https://img.shields.io/github/license/uldyssian-sh/aws-eks-cluster-awscli)](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/blob/main/LICENSE)
[![CI](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/workflows/CI/badge.svg)](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/actions)

## 🚀 Overview

Enterprise-grade AWS EKS cluster management using AWS CLI automation scripts. Streamlines EKS cluster deployment, configuration, and management operations.

**Technology Stack:** AWS CLI, Bash, Kubernetes, YAML

## ✨ Features

- 🔧 **Automated EKS Deployment** - One-click cluster provisioning
- 🔒 **Security Hardening** - Built-in security best practices
- 📊 **Monitoring Integration** - CloudWatch and Prometheus setup
- 🌐 **Multi-AZ Support** - High availability configuration
- 🔄 **Auto-scaling** - Horizontal and vertical pod autoscaling
- 📚 **Comprehensive Logging** - Centralized log management

## 🛠️ Prerequisites

- AWS CLI v2.0+
- kubectl v1.21+
- eksctl v0.100+
- Valid AWS credentials with EKS permissions

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/uldyssian-sh/aws-eks-cluster-awscli.git
cd aws-eks-cluster-awscli

# Configure AWS credentials
aws configure

# Deploy EKS cluster
./scripts/deploy-cluster.sh --cluster-name my-eks --region us-west-2

# Verify deployment
kubectl get nodes
```

## 📋 Cluster Configuration

### Basic Cluster
```bash
./scripts/deploy-cluster.sh \
  --cluster-name production-eks \
  --region us-west-2 \
  --node-type m5.large \
  --nodes 3
```

### Production Cluster
```bash
./scripts/deploy-cluster.sh \
  --cluster-name production-eks \
  --region us-west-2 \
  --node-type m5.xlarge \
  --nodes 5 \
  --enable-logging \
  --enable-monitoring \
  --enable-autoscaling
```

## 🔧 Available Scripts

| Script | Description |
|--------|-------------|
| `deploy-cluster.sh` | Deploy new EKS cluster |
| `update-cluster.sh` | Update existing cluster |
| `delete-cluster.sh` | Delete EKS cluster |
| `scale-nodes.sh` | Scale node groups |
| `install-addons.sh` | Install cluster add-ons |

## 📊 Monitoring & Logging

- **CloudWatch Container Insights** - Cluster metrics
- **AWS Load Balancer Controller** - Ingress management
- **Cluster Autoscaler** - Automatic scaling
- **Fluent Bit** - Log forwarding

## 🔒 Security Features

- IAM roles and policies
- Network security groups
- Pod security standards
- Secrets encryption
- Private endpoint access

## 📚 Documentation

- [Cluster Architecture](docs/architecture.md)
- [Security Guide](docs/security.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Best Practices](docs/best-practices.md)

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
