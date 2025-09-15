#!/usr/bin/env bash
# shellcheck source=.env.template
set -euo pipefail

CYAN="\033[0;36m"; GREEN="\033[0;32m"; NC="\033[0m"

echo -e "${CYAN}=== Configure kubectl for EKS Cluster ===${NC}"

if [ -f .env ]; then
  set -a; source .env; set +a
fi

read -rp "$(echo -e "${CYAN}Cluster name [${CLUSTER_NAME:-eks-demo}]:${NC} ") " CLUSTER_NAME_INPUT
CLUSTER_NAME="${CLUSTER_NAME_INPUT:-${CLUSTER_NAME:-eks-demo}}"

read -rp "$(echo -e "${CYAN}AWS region [${AWS_REGION:-eu-central-1}]:${NC} ") " AWS_REGION_INPUT
AWS_REGION="${AWS_REGION_INPUT:-${AWS_REGION:-eu-central-1}}"

echo -e "${CYAN}Updating kubeconfig...${NC}"
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"

echo -e "${CYAN}Testing connection...${NC}"
kubectl cluster-info
kubectl get nodes

echo -e "${GREEN}kubectl configured successfully!${NC}"