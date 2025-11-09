# Troubleshooting Guide

## Common Issues and Solutions

### 1. Cluster Creation Failures

#### Issue: IAM Permissions Denied
```
Error: User is not authorized to perform: eks:CreateCluster
```

**Solution:**
```bash
# Check your AWS identity
aws sts get-caller-identity

# Ensure you have required permissions
aws iam list-attached-user-policies --user-name your-username
```

#### Issue: VPC Subnet Configuration
```
Error: Subnets must be in at least two different availability zones
```

**Solution:**
- Verify AZ configuration in CloudFormation template
- Check subnet CIDR blocks don't overlap
- Ensure subnets are in different AZs

### 2. Node Group Issues

#### Issue: Nodes Not Joining Cluster
```bash
# Check node status
kubectl get nodes

# Check aws-auth ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml
```

**Solution:**
```bash
# Recreate aws-auth ConfigMap
kubectl delete configmap aws-auth -n kube-system
# Run create-eks.sh again to recreate
```

#### Issue: Insufficient Capacity
```
Error: Cannot create node group due to insufficient capacity
```

**Solution:**
- Try different instance types
- Check service quotas in AWS console
- Use multiple AZs for better availability

### 3. Load Balancer Controller Issues

#### Issue: Controller Not Installing
```bash
# Check controller status
kubectl -n kube-system get deployment aws-load-balancer-controller

# Check logs
kubectl -n kube-system logs deployment/aws-load-balancer-controller
```

**Solution:**
```bash
# Verify IAM role and policy
aws iam get-role --role-name ALBControllerRole-cluster-name

# Check service account annotation
kubectl -n kube-system describe sa aws-load-balancer-controller
```

#### Issue: Ingress Not Creating ALB
```bash
# Check ingress status
kubectl describe ingress your-ingress

# Check controller logs
kubectl -n kube-system logs -l app.kubernetes.io/name=aws-load-balancer-controller
```

**Solution:**
- Verify subnet tags for load balancer discovery
- Check security group rules
- Ensure target type is set correctly

### 4. Networking Issues

#### Issue: Pods Cannot Reach Internet
```bash
# Check pod connectivity
kubectl run test-pod --image=busybox --rm -it -- nslookup google.com
```

**Solution:**
- Verify NAT Gateway configuration
- Check route tables
- Ensure security groups allow outbound traffic

#### Issue: Service Discovery Not Working
```bash
# Test DNS resolution
kubectl run test-pod --image=busybox --rm -it -- nslookup kubernetes.default
```

**Solution:**
- Check CoreDNS pods status
- Verify cluster DNS configuration
- Check network policies

### 5. Storage Issues

#### Issue: PVC Stuck in Pending
```bash
# Check PVC status
kubectl describe pvc your-pvc

# Check storage class
kubectl get storageclass
```

**Solution:**
```bash
# Install EBS CSI driver
aws eks create-addon --cluster-name cluster-name --addon-name aws-ebs-csi-driver

# Check node permissions for EBS
aws iam list-attached-role-policies --role-name eksNodeRole-cluster-name
```

### 6. Monitoring and Debugging

#### Useful Commands
```bash
# Check cluster status
aws eks describe-cluster --name cluster-name

# Check node group status
aws eks describe-nodegroup --cluster-name cluster-name --nodegroup-name ng-1

# Check system pods
kubectl get pods -n kube-system

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces
```

#### Log Locations
```bash
# Controller logs
kubectl -n kube-system logs deployment/aws-load-balancer-controller

# CoreDNS logs
kubectl -n kube-system logs deployment/coredns

# Cluster autoscaler logs
kubectl -n kube-system logs deployment/cluster-autoscaler
```

### 7. Performance Issues

#### Issue: Slow Pod Startup
- Check image pull times
- Verify resource requests/limits
- Check node capacity

#### Issue: High Network Latency
- Verify pod placement across AZs
- Check security group rules
- Monitor network metrics

### 8. Security Issues

#### Issue: RBAC Permissions Denied
```bash
# Check current context
kubectl config current-context

# Check permissions
kubectl auth can-i create pods
kubectl auth can-i create pods --as=system:serviceaccount:default:default
```

**Solution:**
- Review RBAC policies
- Check service account permissions
- Verify cluster admin access

### 9. Cost Optimization

#### Issue: High AWS Costs
- Review instance types and sizes
- Check for unused resources
- Implement cluster autoscaler
- Use Spot instances where appropriate

### 10. Emergency Procedures

#### Complete Cluster Reset
```bash
# Destroy everything
./scripts/destroy-eks.sh
./scripts/delete-vpc.sh

# Recreate from scratch
./scripts/create-vpc.sh
./scripts/create-eks.sh
```

#### Backup Important Data
```bash
# Backup cluster configuration
kubectl get all --all-namespaces -o yaml > cluster-backup.yaml

# Backup persistent volumes
kubectl get pv -o yaml > pv-backup.yaml
```

## Getting Help

### AWS Support
- AWS Support Console
- AWS Forums
- AWS Documentation

### Community Resources
- Kubernetes Slack
- EKS GitHub Issues
- Stack Overflow

### Internal Escalation
1. Check this troubleshooting guide
2. Search internal documentation
3. Contact platform team
4. Escalate to AWS support if needed# Updated Sun Nov  9 12:50:10 CET 2025
# Updated Sun Nov  9 12:52:14 CET 2025
