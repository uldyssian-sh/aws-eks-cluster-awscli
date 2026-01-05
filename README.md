# AWS EKS Cluster with AWS CLI



Enterprise-grade AWS EKS cluster automation using AWS CLI with comprehensive security, monitoring, and cost optimization for GitHub Free tier.


## 🚀 Features

- **Automated EKS Cluster Deployment** - Complete cluster setup with AWS CLI
- **Multi-AZ VPC Configuration** - High availability across 3 availability zones
- **Security Best Practices** - Pod Security Standards, Network Policies, IAM roles
- **Monitoring & Observability** - Prometheus, Grafana integration
- **Cost Optimization** - GitHub Free tier compatible, resource optimization
- **CI/CD Integration** - Automated testing and deployment workflows

## 📋 Prerequisites

- AWS CLI v2.x installed and configured
- kubectl installed
- Helm 3.x installed
- jq for JSON processing
- Valid AWS credentials with EKS permissions

## 🛠️ Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/uldyssian-sh/aws-eks-cluster-awscli.git
   cd aws-eks-cluster-awscli
   ```

2. **Configure environment**
   ```bash
   cp .env.template .env
   # Edit .env with your AWS configuration
   ```

3. **Create VPC infrastructure**
   ```bash
   ./scripts/create-vpc.sh
   ```

4. **Deploy EKS cluster**
   ```bash
   ./scripts/create-eks.sh
   ```

5. **Configure kubectl**
   ```bash
   ./scripts/configure-kubectl.sh
   ```

6. **Install add-ons**
   ```bash
   ./scripts/install-addons.sh
   ```

## 📁 Project Structure

```
├── .github/                 # GitHub workflows and templates
├── cloudformation/          # CloudFormation templates
├── docs/                   # Documentation
│   ├── COST_OPTIMIZATION.md # Cost optimization guide
│   └── SECURITY_BEST_PRACTICES.md # Security guidelines
├── examples/               # Example configurations
├── iam/                    # IAM policies
├── manifests/              # Kubernetes manifests
├── scripts/                # Automation scripts
│   ├── create-eks.sh       # Enhanced EKS creation
│   └── validate-cluster.sh # Cluster validation
├── terraform/              # Terraform configurations
└── tests/                  # Test scripts
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AWS_REGION` | AWS region | `eu-central-1` |
| `CLUSTER_NAME` | EKS cluster name | `eks-demo` |
| `K8S_VERSION` | Kubernetes version | `1.29` |
| `INSTANCE_TYPE` | Node instance type | `t3.medium` |
| `DESIRED_SIZE` | Desired node count | `3` |

### VPC Configuration

The CloudFormation template creates:
- VPC with 3 public and 3 private subnets
- Internet Gateway and NAT Gateway
- Route tables and security groups
- EKS-optimized networking

## 🔒 Security Features

- **Pod Security Standards** - Enforced security policies
- **Network Policies** - Traffic segmentation
- **IAM Roles** - Least privilege access
- **Secrets Management** - Secure credential handling

## 📊 Monitoring

- **Prometheus** - Metrics collection
- **Grafana** - Visualization dashboards
- **Cluster Autoscaler** - Automatic scaling
- **AWS Load Balancer Controller** - Ingress management
- **Health Monitoring** - Automated cluster validation

### Health Checks

The project includes comprehensive health monitoring:
- Automated cluster validation
- Node health verification
- Pod status monitoring
- Network connectivity tests

## 🧪 Testing

Run the test suite:
```bash
./tests/test-cluster.sh
```

### Cluster Validation

Validate cluster health and configuration:
```bash
./scripts/validate-cluster.sh
```

This script checks:
- Cluster status and connectivity
- Node group health
- System pods status
- AWS Load Balancer Controller
- OIDC provider configuration
- Network configuration

## 🚀 Deployment

The repository includes automated CI/CD workflows:
- **CI Pipeline** - Code validation and testing
- **Deployment Pipeline** - Automated infrastructure deployment

## 💰 Cost Optimization

This project is optimized for GitHub Free tier:
- Single NAT Gateway configuration
- t3.medium instances for cost efficiency
- Automated resource cleanup scripts
- Monitoring for cost tracking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- [Issues](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/issues)
- [Discussions](https://github.com/uldyssian-sh/aws-eks-cluster-awscli/discussions)
- [Documentation](docs/)

## 🔗 Related Projects

- [AWS EKS Kasten](https://github.com/uldyssian-sh/aws-eks-cluster-kasten)
- [Enterprise EKS Multi-AZ](https://github.com/uldyssian-sh/aws-eks-ent-multi-az-cluster)

---

Maintained by: uldyssian-sh

⭐ Star this repository if you find it helpful!

Disclaimer: Use of this code is at your own risk. Author bears no responsibility for any damages caused by the code.