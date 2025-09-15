# AWS EKS Cluster with AWS CLI

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Prerequisites

Before using this project, ensure you have:
- Required tools and dependencies
- Proper access credentials
- System requirements met


🚀 **Production-ready automation scripts for deploying Amazon EKS clusters using pure AWS CLI and CloudFormation templates.
Complete infrastructure-as-code solution with VPC, managed node groups, and AWS Load Balancer Controller.**
![Tests](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/actions/workflows/test.yml/badge.svg)
**Author**: LT - [GitHub Profile](https://github.com/uldyssian-sh)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![AWS](https://img.shields.io/badge/AWS-EKS-orange.svg)](https://aws.amazon.com/eks/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.29-blue.svg)](https://kubernetes.io/)

## ✨ Key Features

- 🏗️ **Multi-AZ VPC Infrastructure** - 3 availability zones with public/private subnets
- ⚡ **EKS Cluster v1.29** - Latest Kubernetes with OIDC provider integration
- 🔄 **Auto-Scaling Node Groups** - Managed worker nodes in private subnets
- 🌐 **AWS Load Balancer Controller** - Advanced ingress and load balancing
- 🛡️ **Security Best Practices** - IAM roles, security groups, and network ACLs
- 🧹 **Complete Cleanup** - Automated resource destruction with verification
- 📊 **Cost Optimization** - Efficient resource sizing and cleanup automation
- 🔧 **Interactive Configuration** - Customizable parameters with sensible defaults

## 📋 Prerequisites

### Required Tools

| Tool | Version | Installation Command |
|------|---------|---------------------|
| **AWS CLI** | v2.0+ | `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"` |
| **kubectl** | v1.28+ | `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"` |
| **Helm** | v3.12+ | `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \| bash` |
| **jq** | v1.6+ | `sudo apt-get install jq` (Ubuntu) or `brew install jq` (macOS) |

### AWS Configuration

```bash
# Configure AWS credentials
aws configure
# Follow prompts to enter your AWS credentials
# Default region name: eu-central-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### Required AWS IAM Permissions

Your AWS user/role must have the following permissions:

#### Core Services
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`

#### Infrastructure Management
- `EC2FullAccess` (VPC, subnets, security groups)
- `IAMFullAccess` (create/manage service roles)
- `CloudFormationFullAccess` (deploy/manage stacks)

#### Specific Actions Required
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "iam:*",
        "cloudformation:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### System Requirements
- **Operating System**: Linux, macOS, or WSL2
- **Memory**: 2GB+ RAM available
- **Storage**: 5GB+ free space
- **Network**: Internet connectivity for AWS API calls

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/uldyssian-sh/aws-eks-cluster-awscli.git
cd aws-eks-cluster-awscli
chmod +x scripts/*.sh
```

### 2. Deploy VPC Infrastructure
```bash
./scripts/create-vpc.sh
```
**Input prompts:**
- AWS Region (default: eu-central-1)
- VPC Stack Name (default: eks-vpc)
- VPC CIDR Block (default: 10.0.0.0/16)

**Execution time:** ~5-8 minutes

### 3. Deploy EKS Cluster
```bash
./scripts/create-eks.sh
```
**Input prompts:**
- EKS Cluster Name (default: eks-demo)
- Kubernetes Version (default: 1.29)
- Node Instance Type (default: t3.medium)
- Desired Node Count (default: 3)

**Execution time:** ~15-20 minutes

### 4. Verify Deployment
```bash
# Check cluster status
aws eks describe-cluster --name eks-demo --region eu-central-1

# Verify nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Test AWS Load Balancer Controller
kubectl get deployment -n kube-system aws-load-balancer-controller
```

## 🧹 Cleanup

### 1. Destroy EKS Cluster
```bash
./scripts/destroy-eks.sh
```
**What it removes:**
- EKS Cluster and Node Groups
- AWS Load Balancer Controller
- IAM Roles and Policies
- Security Groups
- OIDC Provider

**Execution time:** ~10-15 minutes

### 2. Destroy VPC Infrastructure
```bash
./scripts/delete-vpc.sh
```
**What it removes:**
- VPC and all subnets
- Internet Gateway and NAT Gateways
- Route Tables and Network ACLs
- CloudFormation Stack

**Execution time:** ~5-8 minutes

### 3. Verification
Both destroy scripts provide detailed verification reports:
```
=== DESTRUCTION COMPLETE - VERIFICATION REPORT ===
✅ EKS Cluster removed: eks-demo
✅ NodeGroup removed: ng-1
✅ IAM Roles removed: 3
✅ Security Groups removed: 2
✅ VPC Stack removed: eks-vpc

🎉 All resources successfully destroyed!
💰 No ongoing AWS charges from this deployment.
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
├─────────────────┬─────────────────┬─────────────────────────┤
│   AZ-A          │   AZ-B          │   AZ-C                  │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Public Subnet   │ Public Subnet   │ Public Subnet           │
│ 10.0.0.0/24     │ 10.0.1.0/24     │ 10.0.2.0/24             │
│                 │                 │                         │
│ Private Subnet  │ Private Subnet  │ Private Subnet          │
│ 10.0.100.0/24   │ 10.0.101.0/24   │ 10.0.102.0/24           │
│                 │                 │                         │
│ [EKS Nodes]     │ [EKS Nodes]     │ [EKS Nodes]             │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## Scripts Overview

| Script | Purpose | Resources Created |
|--------|---------|-------------------|
| `create-vpc.sh` | Deploy VPC infrastructure | VPC, Subnets, IGW, NAT Gateway, Route Tables |
| `create-eks.sh` | Deploy EKS cluster | EKS Cluster, NodeGroup, IAM Roles, OIDC, ALB Controller |
| `destroy-eks.sh` | Remove EKS resources | Removes all EKS-related resources |
| `delete-vpc.sh` | Remove VPC infrastructure | Removes VPC CloudFormation stack |

## Configuration

### Default Values
- **Region**: eu-central-1
- **VPC CIDR**: 10.0.0.0/16
- **Kubernetes Version**: 1.29
- **Instance Type**: t3.medium
- **Node Count**: 3
- **Cluster Name**: eks-demo

### Environment Variables
Scripts create a `.env` file with deployment parameters:
```bash
AWS_REGION=eu-central-1
VPC_STACK_NAME=eks-vpc
VPC_ID=vpc-xxxxx
CLUSTER_NAME=eks-demo
# ... additional variables
```

## IAM Permissions Required

Your AWS user/role needs permissions for:
- EKS (full access)
- EC2 (VPC, subnets, security groups, tags)
- IAM (create/delete roles and policies)
- CloudFormation (create/delete stacks)

## Troubleshooting

### Common Issues

**1. Insufficient IAM permissions**
```bash
# Check your AWS identity
aws sts get-caller-identity
```

**2. Region mismatch**
```bash
# Ensure consistent region usage
export AWS_DEFAULT_REGION=eu-central-1
```

**3. Resource limits**
- Check VPC limits in your region
- Verify EKS service quotas

### Cleanup Verification

The destroy script provides a verification report:
```
=== DESTRUCTION COMPLETE - VERIFICATION REPORT ===
✅ EKS Cluster removed: eks-demo
✅ NodeGroup removed: ng-1
✅ IAM Role removed: eksClusterRole-eks-demo
✅ IAM Role removed: eksNodeRole-eks-demo
✅ IAM Role removed: ALBControllerRole-eks-demo

🎉 All EKS resources successfully destroyed!
```

## File Structure

```
aws-eks-cluster-awscli/
├── scripts/
│   ├── create-vpc.sh          # VPC deployment
│   ├── create-eks.sh          # EKS deployment
│   ├── destroy-eks.sh         # EKS cleanup
│   └── delete-vpc.sh          # VPC cleanup
├── cloudformation/
│   └── vpc-3az.yaml           # VPC CloudFormation template
├── iam/
│   └── aws-load-balancer-controller-policy.json
├── artifacts/                 # Generated files
├── .env                       # Environment variables
└── README.md
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**LT** - [GitHub Profile](https://github.com/uldyssian-sh)

## 🔗 Repository

[aws-eks-cluster-awscli](https://github.com/uldyssian-sh/aws-eks-cluster-awscli)

---

⚠️ **Important**: These scripts create AWS resources that incur costs.
Always run the destroy scripts to clean up resources when done.

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:
- How to submit issues
- How to propose changes
- Code style guidelines
- Review process

## Support

- 📖 [Wiki Documentation](../../wiki)
- 💬 [Discussions](../../discussions)
- 🐛 [Issue Tracker](../../issues)
- 🔒 [Security Policy](SECURITY.md)

---
**Made with ❤️ for the community**
