#!/usr/bin/env bash
set -euo pipefail

CYAN="\033[0;36m"; GREEN="\033[0;32m"; NC="\033[0m"

echo -e "${CYAN}=== Install Monitoring Stack (Prometheus + Grafana) ===${NC}"

echo -e "${CYAN}Adding Prometheus Helm repository...${NC}"
if ! helm repo add prometheus-community https://prometheus-community.github.io/helm-charts; then
    echo "Error: Failed to add Prometheus Helm repository"
    exit 1
fi
if ! helm repo update; then
    echo "Error: Failed to update Helm repositories"
    exit 1
fi

echo -e "${CYAN}Creating monitoring namespace...${NC}"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo -e "${CYAN}Installing Prometheus stack...${NC}"
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values manifests/monitoring/prometheus-values.yaml \
  --wait

echo -e "${CYAN}Waiting for pods to be ready...${NC}"
kubectl -n monitoring wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus --timeout=300s
kubectl -n monitoring wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s

echo -e "${GREEN}Monitoring stack installed!${NC}"
echo -e "${CYAN}Access Grafana:${NC}"
echo "kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "Username: admin"
echo "Get password with: kubectl get secret -n monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 -d"
echo "IMPORTANT: Change the default password after first login!"