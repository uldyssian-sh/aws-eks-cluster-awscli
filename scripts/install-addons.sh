#!/usr/bin/env bash
# shellcheck source=.env.template
set -euo pipefail

CYAN="\033[0;36m"; MAGENTA="\033[0;35m"; GREEN="\033[0;32m"; NC="\033[0m"

echo -e "${MAGENTA}=== Install EKS Add-ons ===${NC}"

if [ -f .env ]; then
  set -a; source .env; set +a
fi

CLUSTER_NAME="${CLUSTER_NAME:-eks-demo}"
AWS_REGION="${AWS_REGION:-eu-central-1}"

echo -e "${CYAN}Installing Cluster Autoscaler...${NC}"
# Replace CLUSTER_NAME placeholder with actual cluster name
sed "s|CLUSTER_NAME|${CLUSTER_NAME}|g" manifests/cluster-autoscaler.yaml | kubectl apply -f -
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler \
  cluster-autoscaler.kubernetes.io/safe-to-evict="false" --overwrite

echo -e "${CYAN}Installing Metrics Server...${NC}"
# Download and verify metrics server manifest
METRICS_SERVER_VERSION="v0.6.4"
METRICS_SERVER_URL="https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml"
echo "Downloading metrics server from: ${METRICS_SERVER_URL}"
if curl -fsSL "${METRICS_SERVER_URL}" -o /tmp/metrics-server.yaml; then
  kubectl apply -f /tmp/metrics-server.yaml
  rm -f /tmp/metrics-server.yaml
else
  echo "Error: Failed to download metrics server manifest"
  exit 1
fi

echo -e "${CYAN}Installing EBS CSI Driver...${NC}"
if ! aws eks create-addon \
  --cluster-name "${CLUSTER_NAME}" \
  --addon-name aws-ebs-csi-driver \
  --region "${AWS_REGION}" 2>/dev/null; then
    echo "EBS CSI Driver addon already exists or failed to create"
fi

echo -e "${GREEN}Add-ons installed successfully!${NC}"# Updated Sun Nov  9 12:50:10 CET 2025
