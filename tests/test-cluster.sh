#!/usr/bin/env bash
# shellcheck source=.env.template
set -euo pipefail

CYAN="\033[0;36m"; GREEN="\033[0;32m"; RED="\033[0;31m"; NC="\033[0m"

echo -e "${CYAN}=== EKS Cluster Test Suite ===${NC}"

# Load environment
if [ -f .env ]; then
  set -a; source .env; set +a
fi

CLUSTER_NAME="${CLUSTER_NAME:-eks-demo}"
AWS_REGION="${AWS_REGION:-eu-central-1}"

# Test functions
test_cluster_status() {
  echo -e "${CYAN}Testing cluster status...${NC}"
  if aws eks describe-cluster --name "${CLUSTER_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Cluster exists and is accessible${NC}"
    return 0
  else
    echo -e "${RED}✗ Cluster not found or not accessible${NC}"
    return 1
  fi
}

test_kubectl_connectivity() {
  echo -e "${CYAN}Testing kubectl connectivity...${NC}"
  if kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${GREEN}✓ kubectl can connect to cluster${NC}"
    return 0
  else
    echo -e "${RED}✗ kubectl cannot connect to cluster${NC}"
    return 1
  fi
}

test_nodes_ready() {
  echo -e "${CYAN}Testing node readiness...${NC}"
  local ready_nodes
  ready_nodes=$(kubectl get nodes --no-headers | grep -c "Ready" || echo "0")
  if [ "${ready_nodes}" -gt 0 ]; then
    echo -e "${GREEN}✓ ${ready_nodes} nodes are ready${NC}"
    return 0
  else
    echo -e "${RED}✗ No nodes are ready${NC}"
    return 1
  fi
}

test_system_pods() {
  echo -e "${CYAN}Testing system pods...${NC}"
  local failed_pods
  failed_pods=$(kubectl get pods -n kube-system --no-headers | grep -vc "Running\|Completed")
  if [ "${failed_pods}" -eq 0 ]; then
    echo -e "${GREEN}✓ All system pods are running${NC}"
    return 0
  else
    echo -e "${RED}✗ ${failed_pods} system pods are not running${NC}"
    kubectl get pods -n kube-system --no-headers | grep -v "Running\|Completed" || true
    return 1
  fi
}

test_load_balancer_controller() {
  echo -e "${CYAN}Testing AWS Load Balancer Controller...${NC}"
  if kubectl get deployment -n kube-system aws-load-balancer-controller >/dev/null 2>&1; then
    local ready_replicas
    ready_replicas=$(kubectl get deployment -n kube-system aws-load-balancer-controller -o jsonpath='{.status.readyReplicas}')
    if [ "${ready_replicas:-0}" -gt 0 ]; then
      echo -e "${GREEN}✓ AWS Load Balancer Controller is running${NC}"
      return 0
    else
      echo -e "${RED}✗ AWS Load Balancer Controller is not ready${NC}"
      return 1
    fi
  else
    echo -e "${RED}✗ AWS Load Balancer Controller not found${NC}"
    return 1
  fi
}

test_dns_resolution() {
  echo -e "${CYAN}Testing DNS resolution...${NC}"
  if kubectl run test-dns --image=busybox --rm -i --restart=Never -- nslookup kubernetes.default >/dev/null 2>&1; then
    echo -e "${GREEN}✓ DNS resolution is working${NC}"
    return 0
  else
    echo -e "${RED}✗ DNS resolution failed${NC}"
    return 1
  fi
}

test_internet_connectivity() {
  echo -e "${CYAN}Testing internet connectivity...${NC}"
  if kubectl run test-internet --image=busybox --rm -i --restart=Never -- wget -q --spider google.com >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Internet connectivity is working${NC}"
    return 0
  else
    echo -e "${RED}✗ Internet connectivity failed${NC}"
    return 1
  fi
}

test_storage_class() {
  echo -e "${CYAN}Testing storage class...${NC}"
  if kubectl get storageclass gp2 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Default storage class exists${NC}"
    return 0
  else
    echo -e "${RED}✗ Default storage class not found${NC}"
    return 1
  fi
}

# Run all tests
run_tests() {
  local failed=0
  
  test_cluster_status || ((failed++))
  test_kubectl_connectivity || ((failed++))
  test_nodes_ready || ((failed++))
  test_system_pods || ((failed++))
  test_load_balancer_controller || ((failed++))
  test_dns_resolution || ((failed++))
  test_internet_connectivity || ((failed++))
  test_storage_class || ((failed++))
  
  echo
  if [ "${failed}" -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Cluster is healthy.${NC}"
    return 0
  else
    echo -e "${RED}❌ ${failed} test(s) failed. Please check the issues above.${NC}"
    return 1
  fi
}

# Main execution
case "${1:-all}" in
  "cluster")
    test_cluster_status
    ;;
  "kubectl")
    test_kubectl_connectivity
    ;;
  "nodes")
    test_nodes_ready
    ;;
  "pods")
    test_system_pods
    ;;
  "alb")
    test_load_balancer_controller
    ;;
  "dns")
    test_dns_resolution
    ;;
  "internet")
    test_internet_connectivity
    ;;
  "storage")
    test_storage_class
    ;;
  "all"|*)
    run_tests
    ;;
esac