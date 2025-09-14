# Discussion Topics for AWS EKS Cluster

## Architecture & Design

**Q: Multi-region EKS deployment**
Planning to deploy EKS clusters across us-east-1 and eu-west-1. What are the key networking considerations? Particularly interested in cross-region communication and latency optimization.

**Q: Node group sizing strategies**
What's the recommended approach for sizing node groups in production? Currently using t3.medium but considering mixed instance types for cost optimization.

## Security & Compliance

**Q: RBAC best practices**
Looking for real-world examples of RBAC configurations for multi-team environments. How do you handle namespace isolation and cross-team resource sharing?

**Q: Network security hardening**
What additional security measures do you implement beyond the default VPC configuration? Interested in network policies and ingress controller security.

## Operations & Monitoring

**Q: Cluster autoscaling tuning**
Having issues with cluster autoscaler being too aggressive. What parameters do you tune for stable scaling in production workloads?

**Q: Logging and monitoring stack**
What's your preferred monitoring setup? Currently evaluating between CloudWatch Container Insights vs. Prometheus/Grafana stack.

## Cost Optimization

**Q: Spot instance integration**
Anyone successfully running production workloads on spot instances? What's your strategy for handling interruptions and maintaining availability?

**Q: Resource optimization**
Best practices for right-sizing resources and avoiding over-provisioning? Tools and techniques for ongoing cost monitoring?

## Troubleshooting

**Q: Pod networking issues**
Experiencing intermittent pod-to-pod communication failures. CNI plugin is AWS VPC CNI. Any common configuration issues to check?

**Q: Storage performance**
EBS volumes showing high latency. What storage classes and configurations work best for database workloads on EKS?