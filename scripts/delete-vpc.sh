#!/usr/bin/env bash
# shellcheck source=.env.template
set -euo pipefail

CYAN="\033[0;36m"; MAGENTA="\033[0;35m"; GREEN="\033[0;32m"; NC="\033[0m"

echo -e "${MAGENTA}=== Delete VPC CloudFormation Stack ===${NC}"

if [ -f .env ]; then set -a; source .env; set +a; fi

read -rp "$(echo -e "${CYAN}VPC stack name [${VPC_STACK_NAME:-eks-vpc}]:${NC}") " VPC_STACK_INPUT
VPC_STACK_NAME="${VPC_STACK_INPUT:-${VPC_STACK_NAME:-eks-vpc}}"

read -rp "$(echo -e "${CYAN}AWS region [${AWS_REGION:-eu-central-1}]:${NC}") " AWS_REGION_INPUT
AWS_REGION="${AWS_REGION_INPUT:-${AWS_REGION:-eu-central-1}}"

if ! aws cloudformation delete-stack --stack-name "${VPC_STACK_NAME}" --region "${AWS_REGION}" 2>/dev/null; then
  echo "Warning: Failed to delete stack or stack does not exist: ${VPC_STACK_NAME}"
else
  echo -e "${MAGENTA}Waiting for stack deletion...${NC}"
  if ! aws cloudformation wait stack-delete-complete --stack-name "${VPC_STACK_NAME}" --region "${AWS_REGION}" 2>/dev/null; then
    echo "Warning: Stack deletion may have failed or timed out"
  fi
fi

echo -e "${GREEN}VPC stack ${VPC_STACK_NAME} deleted.${NC}"
