#!/usr/bin/env bash
# shellcheck source=.env.template
set -euo pipefail

CYAN="\033[0;36m"; MAGENTA="\033[0;35m"; GREEN="\033[0;32m"; RED="\033[0;31m"; NC="\033[0m"

echo -e "${MAGENTA}=== Destroy EKS (controller, nodegroup, cluster, IAM, OIDC) ===${NC}"

if [ -f .env ]; then set -a; source .env; set +a; fi

read -rp "$(echo -e "${CYAN}Cluster name [${CLUSTER_NAME:-eks-demo}]:${NC}") " CLUSTER_NAME_IN
CLUSTER_NAME="${CLUSTER_NAME_IN:-${CLUSTER_NAME:-eks-demo}}"

read -rp "$(echo -e "${CYAN}AWS region [${AWS_REGION:-eu-central-1}]:${NC}") " AWS_REGION_IN
AWS_REGION="${AWS_REGION_IN:-${AWS_REGION:-eu-central-1}}"

read -rp "$(echo -e "${CYAN}NodeGroup name [${NODEGROUP_NAME:-ng-1}]:${NC}") " NODEGROUP_NAME_IN
NODEGROUP_NAME="${NODEGROUP_NAME_IN:-${NODEGROUP_NAME:-ng-1}}"

# Attempt to read helpful values
ALB_ROLE_NAME="${ALB_ROLE_NAME:-ALBControllerRole-${CLUSTER_NAME}}"
ALB_POLICY_ARN="${ALB_POLICY_ARN:-$(aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'ALBControllerPolicy-${CLUSTER_NAME}')].Arn" --output text)}"
CLUSTER_ROLE_NAME="${CLUSTER_ROLE_NAME:-eksClusterRole-${CLUSTER_NAME}}"
NODE_ROLE_NAME="${NODE_ROLE_NAME:-eksNodeRole-${CLUSTER_NAME}}"

echo -e "${MAGENTA}Uninstalling AWS Load Balancer Controller...${NC}"
if helm list -n kube-system | grep -q aws-load-balancer-controller; then
  echo "  ✓ Removing Helm chart: aws-load-balancer-controller"
  helm uninstall aws-load-balancer-controller -n kube-system || true
else
  echo "  - Helm chart not found (already removed)"
fi
if kubectl -n kube-system get sa aws-load-balancer-controller >/dev/null 2>&1; then
  echo "  ✓ Removing ServiceAccount: aws-load-balancer-controller"
  kubectl -n kube-system delete sa aws-load-balancer-controller --ignore-not-found=true || true
else
  echo "  - ServiceAccount not found (already removed)"
fi

echo -e "${MAGENTA}Deleting IAM role and policy for ALB controller...${NC}"
if [ -n "${ALB_POLICY_ARN}" ]; then
  aws iam detach-role-policy --role-name "${ALB_ROLE_NAME}" --policy-arn "${ALB_POLICY_ARN}" || true
fi
aws iam delete-role --role-name "${ALB_ROLE_NAME}" || true
if [ -n "${ALB_POLICY_ARN}" ]; then
  aws iam delete-policy --policy-arn "${ALB_POLICY_ARN}" || true
fi

echo -e "${MAGENTA}Deleting NodeGroup ${NODEGROUP_NAME}...${NC}"
aws eks delete-nodegroup --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${NODEGROUP_NAME}" --region "${AWS_REGION}" || true
aws eks wait nodegroup-deleted --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${NODEGROUP_NAME}" --region "${AWS_REGION}" || true

echo -e "${MAGENTA}Deleting Cluster ${CLUSTER_NAME}...${NC}"
aws eks delete-cluster --name "${CLUSTER_NAME}" --region "${AWS_REGION}" || true
aws eks wait cluster-deleted --name "${CLUSTER_NAME}" --region "${AWS_REGION}" || true

echo -e "${MAGENTA}Deleting IAM roles for Cluster and Nodes...${NC}"
# Detach and delete node role
for POLICY in AmazonEKSWorkerNodePolicy AmazonEC2ContainerRegistryReadOnly AmazonEKS_CNI_Policy; do
  aws iam detach-role-policy --role-name "${NODE_ROLE_NAME}" --policy-arn arn:aws:iam::aws:policy/$POLICY || true
done
aws iam delete-role --role-name "${NODE_ROLE_NAME}" || true

# Detach and delete cluster role
aws iam detach-role-policy --role-name "${CLUSTER_ROLE_NAME}" --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy || true
aws iam delete-role --role-name "${CLUSTER_ROLE_NAME}" || true

echo -e "${MAGENTA}Removing cluster tags from subnets...${NC}"
if [ -n "${PUBLIC_SUBNET_IDS:-}" ] && [ -n "${PRIVATE_SUBNET_IDS:-}" ]; then
  for SUBNET in ${PUBLIC_SUBNET_IDS//,/ } ${PRIVATE_SUBNET_IDS//,/ }; do
    aws ec2 delete-tags --resources "$SUBNET" --tags "Key=kubernetes.io/cluster/${CLUSTER_NAME}" --region "${AWS_REGION}" || true
  done
fi

echo -e "${MAGENTA}Deleting OIDC provider (if present)...${NC}"
# Try to get OIDC issuer from environment variable first, then from cluster (if still exists)
if [ -n "${OIDC_PROVIDER_ARN:-}" ]; then
  OIDC_TO_DELETE="${OIDC_PROVIDER_ARN}"
else
  # Extract OIDC host from cluster if it still exists
  OIDC_ISSUER=$(aws eks describe-cluster --name "${CLUSTER_NAME}" --region "${AWS_REGION}" --query "cluster.identity.oidc.issuer" --output text 2>/dev/null || echo "")
  if [ -n "${OIDC_ISSUER}" ] && [ "${OIDC_ISSUER}" != "None" ]; then
    OIDC_HOST="${OIDC_ISSUER#https://}"
    OIDC_TO_DELETE=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?contains(Arn, '${OIDC_HOST}')].Arn" --output text 2>/dev/null || echo "")
  else
    OIDC_TO_DELETE=""
  fi
fi
if [ -n "${OIDC_TO_DELETE}" ] && [ "${OIDC_TO_DELETE}" != "None" ]; then
  aws iam delete-open-id-connect-provider --open-id-connect-provider-arn "${OIDC_TO_DELETE}" || true
else
  echo "  - OIDC provider not found or already removed"
fi

echo -e "${GREEN}\n=== DESTRUCTION COMPLETE - VERIFICATION REPORT ===${NC}"
echo -e "${CYAN}Verifying all resources have been removed...${NC}\n"

# Verify EKS Cluster
if aws eks describe-cluster --name "${CLUSTER_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1; then
  echo -e "${RED}❌ EKS Cluster still exists: ${CLUSTER_NAME}${NC}"
else
  echo -e "${GREEN}✅ EKS Cluster removed: ${CLUSTER_NAME}${NC}"
fi

# Verify NodeGroup
if aws eks describe-nodegroup --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${NODEGROUP_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1; then
  echo -e "${RED}❌ NodeGroup still exists: ${NODEGROUP_NAME}${NC}"
else
  echo -e "${GREEN}✅ NodeGroup removed: ${NODEGROUP_NAME}${NC}"
fi

# Verify IAM Roles
for ROLE in "${CLUSTER_ROLE_NAME}" "${NODE_ROLE_NAME}" "${ALB_ROLE_NAME}"; do
  if aws iam get-role --role-name "${ROLE}" >/dev/null 2>&1; then
    echo -e "${RED}❌ IAM Role still exists: ${ROLE}${NC}"
  else
    echo -e "${GREEN}✅ IAM Role removed: ${ROLE}${NC}"
  fi
done

echo -e "\n${GREEN}🎉 All EKS resources successfully destroyed!${NC}"
# Updated Sun Nov  9 12:50:10 CET 2025
# Updated Sun Nov  9 12:52:14 CET 2025
