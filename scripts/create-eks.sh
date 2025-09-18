#!/usr/bin/env bash
# shellcheck source=.env.template
set -euo pipefail

CYAN="\033[0;36m"; MAGENTA="\033[0;35m"; GREEN="\033[0;32m"; RED="\033[0;31m"; NC="\033[0m"

echo -e "${MAGENTA}=== EKS Cluster + NodeGroup + OIDC + AWS Load Balancer Controller ===${NC}"

# Load env if present
if [ -f .env ]; then
  set -a; source .env; set +a
fi

read -rp "$(echo -e "${CYAN}Cluster name [eks-demo]:${NC}") " CLUSTER_NAME
CLUSTER_NAME="${CLUSTER_NAME:-eks-demo}"

read -rp "$(echo -e "${CYAN}Kubernetes version [1.29]:${NC}") " K8S_VERSION
K8S_VERSION="${K8S_VERSION:-1.29}"

read -rp "$(echo -e "${CYAN}Node group name [ng-1]:${NC}") " NODEGROUP_NAME
NODEGROUP_NAME="${NODEGROUP_NAME:-ng-1}"

read -rp "$(echo -e "${CYAN}Worker instance type [t3.medium]:${NC}") " INSTANCE_TYPE
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.medium}"

read -rp "$(echo -e "${CYAN}Desired worker count [3]:${NC}") " DESIRED_SIZE
DESIRED_SIZE="${DESIRED_SIZE:-3}"

read -rp "$(echo -e "${CYAN}AWS region [${AWS_REGION:-eu-central-1}]:${NC}") " AWS_REGION_INPUT
AWS_REGION="${AWS_REGION_INPUT:-${AWS_REGION:-eu-central-1}}"

read -rp "$(echo -e "${CYAN}VPC stack name [${VPC_STACK_NAME:-eks-vpc}]:${NC}") " VPC_STACK_INPUT
VPC_STACK_NAME="${VPC_STACK_INPUT:-${VPC_STACK_NAME:-eks-vpc}}"

echo -e "${MAGENTA}Retrieving VPC and Subnets from stack ${VPC_STACK_NAME}...${NC}"
if ! STACK_JSON=$(aws cloudformation describe-stacks --stack-name "${VPC_STACK_NAME}" --region "${AWS_REGION}" 2>/dev/null); then
  echo -e "${RED:-\033[0;31m}Error: CloudFormation stack '${VPC_STACK_NAME}' not found in region '${AWS_REGION}'${NC}"
  exit 1
fi

VPC_ID=$(echo "$STACK_JSON" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VpcId") | .OutputValue')
PUBLIC_SUBNET_IDS=$(echo "$STACK_JSON" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubnetIds") | .OutputValue')
PRIVATE_SUBNET_IDS=$(echo "$STACK_JSON" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubnetIds") | .OutputValue')

# Validate required outputs
if [[ -z "$VPC_ID" || "$VPC_ID" == "null" ]]; then
  echo -e "${RED:-\033[0;31m}Error: VPC ID not found in stack outputs${NC}"
  exit 1
fi
if [[ -z "$PUBLIC_SUBNET_IDS" || "$PUBLIC_SUBNET_IDS" == "null" ]]; then
  echo -e "${RED:-\033[0;31m}Error: Public subnet IDs not found in stack outputs${NC}"
  exit 1
fi
if [[ -z "$PRIVATE_SUBNET_IDS" || "$PRIVATE_SUBNET_IDS" == "null" ]]; then
  echo -e "${RED:-\033[0;31m}Error: Private subnet IDs not found in stack outputs${NC}"
  exit 1
fi

IFS=',' read -r PUB1 PUB2 PUB3 <<< "${PUBLIC_SUBNET_IDS}"
IFS=',' read -r PRV1 PRV2 PRV3 <<< "${PRIVATE_SUBNET_IDS}"

# Validate subnet parsing
if [[ -z "$PUB1" || -z "$PUB2" || -z "$PUB3" ]]; then
  echo -e "${RED:-\033[0;31m}Error: Expected 3 public subnets, got: ${PUBLIC_SUBNET_IDS}${NC}"
  exit 1
fi
if [[ -z "$PRV1" || -z "$PRV2" || -z "$PRV3" ]]; then
  echo -e "${RED:-\033[0;31m}Error: Expected 3 private subnets, got: ${PRIVATE_SUBNET_IDS}${NC}"
  exit 1
fi

echo -e "${MAGENTA}Creating IAM role for EKS Cluster...${NC}"
CLUSTER_ROLE_NAME="eksClusterRole-${CLUSTER_NAME}"
aws iam create-role --role-name "${CLUSTER_ROLE_NAME}" \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "eks.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }' >/dev/null || true
aws iam attach-role-policy --role-name "${CLUSTER_ROLE_NAME}" --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy >/dev/null || true

CLUSTER_ROLE_ARN=$(aws iam get-role --role-name "${CLUSTER_ROLE_NAME}" --query 'Role.Arn' --output text)

echo -e "${MAGENTA}Creating EKS Cluster ${CLUSTER_NAME}... (this can take several minutes)${NC}"
if ! aws eks create-cluster \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --kubernetes-version "${K8S_VERSION}" \
  --role-arn "${CLUSTER_ROLE_ARN}" \
  --resources-vpc-config subnetIds="${PRV1},${PRV2},${PRV3},${PUB1},${PUB2},${PUB3}" 2>/dev/null; then
    echo "Cluster already exists or creation failed"
fi

aws eks wait cluster-active --name "${CLUSTER_NAME}" --region "${AWS_REGION}"
echo -e "${GREEN}Cluster is ACTIVE${NC}"

echo -e "${MAGENTA}Update kubeconfig...${NC}"
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}" >/dev/null

echo -e "${MAGENTA}Creating IAM role for NodeGroup...${NC}"
NODE_ROLE_NAME="eksNodeRole-${CLUSTER_NAME}"
aws iam create-role --role-name "${NODE_ROLE_NAME}" \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }' >/dev/null || true

aws iam attach-role-policy --role-name "${NODE_ROLE_NAME}" --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy >/dev/null || true
aws iam attach-role-policy --role-name "${NODE_ROLE_NAME}" --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly >/dev/null || true
aws iam attach-role-policy --role-name "${NODE_ROLE_NAME}" --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy >/dev/null || true
NODE_ROLE_ARN=$(aws iam get-role --role-name "${NODE_ROLE_NAME}" --query 'Role.Arn' --output text)

echo -e "${MAGENTA}Creating NodeGroup ${NODEGROUP_NAME} with ${DESIRED_SIZE}x ${INSTANCE_TYPE} in private subnets...${NC}"
aws eks create-nodegroup \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --nodegroup-name "${NODEGROUP_NAME}" \
  --node-role "${NODE_ROLE_ARN}" \
  --subnets "${PRV1}" "${PRV2}" "${PRV3}" \
  --scaling-config "minSize=${DESIRED_SIZE},maxSize=$((DESIRED_SIZE+3)),desiredSize=${DESIRED_SIZE}" \
  --instance-types "${INSTANCE_TYPE}" >/dev/null

aws eks wait nodegroup-active --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${NODEGROUP_NAME}" --region "${AWS_REGION}"
echo -e "${GREEN}NodeGroup is ACTIVE${NC}"

# Ensure nodes can join (aws-auth mapping for the Node role)
echo -e "${MAGENTA}Applying aws-auth ConfigMap for node IAM role...${NC}"
kubectl delete configmap aws-auth -n kube-system 2>/dev/null || true
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${NODE_ROLE_ARN}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF

echo -e "${MAGENTA}Associating OIDC provider for IRSA...${NC}"
OIDC_ISSUER=$(aws eks describe-cluster --name "${CLUSTER_NAME}" --region "${AWS_REGION}" --query "cluster.identity.oidc.issuer" --output text)
OIDC_HOST="${OIDC_ISSUER#https://}"
# Use standard EKS OIDC thumbprint
THUMBPRINT="9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
aws iam create-open-id-connect-provider \
  --url "${OIDC_ISSUER}" \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list "${THUMBPRINT}" >/dev/null || true

OIDC_PROVIDER_ARN=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?contains(Arn, '${OIDC_HOST}')].Arn" --output text)

echo -e "${MAGENTA}Creating IAM policy and role for AWS Load Balancer Controller...${NC}"
ALB_POLICY_NAME="ALBControllerPolicy-${CLUSTER_NAME}"
# Create or get policy ARN
ALB_POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='${ALB_POLICY_NAME}'].Arn" --output text)
if [ -z "${ALB_POLICY_ARN}" ]; then
  ALB_POLICY_ARN=$(aws iam create-policy --policy-name "${ALB_POLICY_NAME}" --policy-document file://iam/aws-load-balancer-controller-policy.json --query 'Policy.Arn' --output text)
fi

ALB_ROLE_NAME="ALBControllerRole-${CLUSTER_NAME}"
mkdir -p artifacts
cat > artifacts/alb-trust-policy.json <<TP
{
  "Version": "2012-10-17",
  "Statement": [ {
    "Effect": "Allow",
    "Principal": { "Federated": "${OIDC_PROVIDER_ARN}" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "${OIDC_HOST}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller",
        "${OIDC_HOST}:aud": "sts.amazonaws.com"
      }
    }
  } ]
}
TP

aws iam create-role --role-name "${ALB_ROLE_NAME}" \
  --assume-role-policy-document file://artifacts/alb-trust-policy.json >/dev/null || true
aws iam attach-role-policy --role-name "${ALB_ROLE_NAME}" --policy-arn "${ALB_POLICY_ARN}" >/dev/null || true
ALB_ROLE_ARN=$(aws iam get-role --role-name "${ALB_ROLE_NAME}" --query 'Role.Arn' --output text)

echo -e "${MAGENTA}Creating ServiceAccount for controller and annotating with IAM role...${NC}"
kubectl create serviceaccount -n kube-system aws-load-balancer-controller >/dev/null || true
kubectl annotate serviceaccount -n kube-system aws-load-balancer-controller \
  eks.amazonaws.com/role-arn="${ALB_ROLE_ARN}" --overwrite

echo -e "${MAGENTA}Installing AWS Load Balancer Controller via Helm...${NC}"
helm repo add eks https://aws.github.io/eks-charts || true
helm repo update
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="${CLUSTER_NAME}" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region="${AWS_REGION}" \
  --set vpcId="${VPC_ID}" >/dev/null

echo -e "${GREEN}Controller installed. Verifying...${NC}"
kubectl -n kube-system rollout status deploy/aws-load-balancer-controller

# Tag subnets for cluster usage (shared)
echo -e "${MAGENTA}Tagging subnets for cluster discovery...${NC}"
for SUBNET in ${PUBLIC_SUBNET_IDS//,/ } ${PRIVATE_SUBNET_IDS//,/ }; do
  aws ec2 create-tags --resources "$SUBNET" --tags "Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared" --region "${AWS_REGION}" >/dev/null || true
done

mkdir -p artifacts
cat > artifacts/eks-outputs.json <<JSON
{
  "ClusterName": "${CLUSTER_NAME}",
  "Region": "${AWS_REGION}",
  "KubernetesVersion": "${K8S_VERSION}",
  "VpcId": "${VPC_ID}",
  "PublicSubnetIds": "${PUBLIC_SUBNET_IDS}",
  "PrivateSubnetIds": "${PRIVATE_SUBNET_IDS}",
  "ClusterRoleName": "${CLUSTER_ROLE_NAME}",
  "NodeRoleName": "${NODE_ROLE_NAME}",
  "NodeRoleArn": "${NODE_ROLE_ARN}",
  "AlbPolicyArn": "${ALB_POLICY_ARN}",
  "AlbRoleName": "${ALB_ROLE_NAME}",
  "OidcProviderArn": "${OIDC_PROVIDER_ARN}",
  "NodeGroupName": "${NODEGROUP_NAME}"
}
JSON

cat >> .env <<ENV
CLUSTER_NAME=${CLUSTER_NAME}
NODEGROUP_NAME=${NODEGROUP_NAME}
K8S_VERSION=${K8S_VERSION}
INSTANCE_TYPE=${INSTANCE_TYPE}
DESIRED_SIZE=${DESIRED_SIZE}
CLUSTER_ROLE_NAME=${CLUSTER_ROLE_NAME}
NODE_ROLE_NAME=${NODE_ROLE_NAME}
ALB_POLICY_ARN=${ALB_POLICY_ARN}
ALB_ROLE_NAME=${ALB_ROLE_NAME}
OIDC_PROVIDER_ARN=${OIDC_PROVIDER_ARN}
ENV

echo -e "${GREEN}EKS cluster ready!${NC}"
