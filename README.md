# AWS EKS Production Cluster

> Enterprise-grade Amazon EKS cluster automation and management solution

[![Deploy](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/actions/workflows/deploy.yml/badge.svg)](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/actions/workflows/deploy.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Quick Start

```bash
# Prerequisites: AWS CLI, kubectl, eksctl
aws configure
git clone https://github.com/uldyssian-sh/aws-eks-cluster-awscli.git
cd aws-eks-cluster-awscli

# Deploy cluster
./scripts/deploy.sh --region us-west-2 --cluster-name production
```

## Architecture

- **Control Plane**: Managed by AWS EKS
- **Worker Nodes**: Auto Scaling Groups with Spot instances
- **Networking**: VPC with private/public subnets
- **Security**: IAM roles, Security Groups, Pod Security Standards

## Features

| Feature | Status | Description |
|---------|--------|-------------|
| Auto Scaling | ✅ | Horizontal Pod Autoscaler + Cluster Autoscaler |
| Load Balancing | ✅ | AWS Load Balancer Controller |
| Monitoring | ✅ | CloudWatch Container Insights |
| Logging | ✅ | Fluent Bit to CloudWatch Logs |
| Security | ✅ | Pod Security Standards, Network Policies |

## Configuration

```yaml
# cluster-config.yaml
cluster:
  name: production-eks
  region: us-west-2
  version: "1.28"
  
nodeGroups:
  - name: workers
    instanceType: m5.large
    minSize: 2
    maxSize: 10
    spotInstances: true
```

## Deployment Environments

- **Development**: `dev.example.com`
- **Staging**: `staging.example.com`  
- **Production**: `prod.example.com`

## Monitoring & Alerts

Access cluster metrics at: `https://console.aws.amazon.com/cloudwatch/`

## Troubleshooting

```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# View logs
kubectl logs -f deployment/app-name
```

## Cost Optimization

- Spot instances for non-critical workloads
- Cluster autoscaler for right-sizing
- Reserved instances for baseline capacity

---
**Maintained by**: [uldyssian-sh](https://github.com/uldyssian-sh) | **License**: MIT