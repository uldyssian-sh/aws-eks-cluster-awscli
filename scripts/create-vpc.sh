#!/usr/bin/env bash
# shellcheck source=.env.template
set -euo pipefail

# ANSI colors
CYAN="\033[0;36m"; MAGENTA="\033[0;35m"; GREEN="\033[0;32m"; NC="\033[0m"

echo -e "${MAGENTA}=== VPC Creation (3 AZs, 3x public + 3x private, 1 NAT GW) ===${NC}"

read -rp "$(echo -e "${CYAN}Enter CloudFormation stack name [eks-vpc]:${NC}") " STACK_NAME
STACK_NAME="${STACK_NAME:-eks-vpc}"

read -rp "$(echo -e "${CYAN}Environment name tag [eks]:${NC}") " ENV_NAME
ENV_NAME="${ENV_NAME:-eks}"

read -rp "$(echo -e "${CYAN}AWS region [eu-central-1]:${NC}") " AWS_REGION
AWS_REGION="${AWS_REGION:-eu-central-1}"

read -rp "$(echo -e "${CYAN}AZ letters (comma) [a,b,c]:${NC}") " AZ_LETTERS
AZ_LETTERS="${AZ_LETTERS:-a,b,c}"

read -rp "$(echo -e "${CYAN}VPC CIDR [10.0.0.0/16]:${NC}") " VPC_CIDR
VPC_CIDR="${VPC_CIDR:-10.0.0.0/16}"

# Default subnet CIDRs
PUB_CIDRS_DEFAULT="10.0.0.0/24,10.0.1.0/24,10.0.2.0/24"
PRV_CIDRS_DEFAULT="10.0.100.0/24,10.0.101.0/24,10.0.102.0/24"

read -rp "$(echo -e "${CYAN}Public subnet CIDRs [${PUB_CIDRS_DEFAULT}]:${NC}") " PUBLIC_CIDRS
PUBLIC_CIDRS="${PUBLIC_CIDRS:-$PUB_CIDRS_DEFAULT}"

read -rp "$(echo -e "${CYAN}Private subnet CIDRs [${PRV_CIDRS_DEFAULT}]:${NC}") " PRIVATE_CIDRS
PRIVATE_CIDRS="${PRIVATE_CIDRS:-$PRV_CIDRS_DEFAULT}"

CFN_TEMPLATE="cloudformation/vpc-3az.yaml"

# Check if template file exists
if [[ ! -f "$CFN_TEMPLATE" ]]; then
  echo "Error: Template file not found: $CFN_TEMPLATE"
  exit 1
fi

echo -e "${MAGENTA}Deploying CloudFormation stack ${STACK_NAME} in ${AWS_REGION}...${NC}"
aws cloudformation deploy \
  --stack-name "${STACK_NAME}" \
  --template-file "${CFN_TEMPLATE}" \
  --region "${AWS_REGION}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EnvironmentName="${ENV_NAME}" \
    VpcCidr="${VPC_CIDR}" \
    Region="${AWS_REGION}" \
    AzLetters="${AZ_LETTERS}" \
    PublicSubnetCidrs="${PUBLIC_CIDRS}" \
    PrivateSubnetCidrs="${PRIVATE_CIDRS}"

echo -e "${MAGENTA}Fetching outputs...${NC}"
if ! STACK_JSON=$(aws cloudformation describe-stacks --stack-name "${STACK_NAME}" --region "${AWS_REGION}" 2>/dev/null); then
  echo -e "${RED:-\033[0;31m}Error: Failed to describe CloudFormation stack${NC}" >&2
  exit 1
fi

VPC_ID=$(echo "$STACK_JSON" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VpcId") | .OutputValue')
PUBLIC_SUBNET_IDS=$(echo "$STACK_JSON" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubnetIds") | .OutputValue')
PRIVATE_SUBNET_IDS=$(echo "$STACK_JSON" | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubnetIds") | .OutputValue')

# Validate extracted values
if [[ -z "$VPC_ID" || "$VPC_ID" == "null" ]]; then
  echo -e "${RED:-\033[0;31m}Error: VPC ID not found in stack outputs${NC}" >&2
  exit 1
fi
if [[ -z "$PUBLIC_SUBNET_IDS" || "$PUBLIC_SUBNET_IDS" == "null" ]]; then
  echo -e "${RED:-\033[0;31m}Error: Public subnet IDs not found in stack outputs${NC}" >&2
  exit 1
fi
if [[ -z "$PRIVATE_SUBNET_IDS" || "$PRIVATE_SUBNET_IDS" == "null" ]]; then
  echo -e "${RED:-\033[0;31m}Error: Private subnet IDs not found in stack outputs${NC}" >&2
  exit 1
fi

mkdir -p artifacts
cat > artifacts/vpc-outputs.json <<JSON
{
  "StackName": "${STACK_NAME}",
  "Region": "${AWS_REGION}",
  "VpcId": "${VPC_ID}",
  "PublicSubnetIds": "${PUBLIC_SUBNET_IDS}",
  "PrivateSubnetIds": "${PRIVATE_SUBNET_IDS}"
}
JSON

cat > .env <<ENV
AWS_REGION=${AWS_REGION}
VPC_STACK_NAME=${STACK_NAME}
VPC_ID=${VPC_ID}
PUBLIC_SUBNET_IDS=${PUBLIC_SUBNET_IDS}
PRIVATE_SUBNET_IDS=${PRIVATE_SUBNET_IDS}
ENV

echo -e "${GREEN}VPC created. VPC_ID=${VPC_ID}${NC}"
# Updated Sun Nov  9 12:50:10 CET 2025
# Updated Sun Nov  9 12:52:14 CET 2025
