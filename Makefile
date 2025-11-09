.PHONY: help vpc eks destroy-eks destroy-vpc test clean lint

# Default target
help:
	@echo "Available targets:"
	@echo "  vpc          - Create VPC infrastructure"
	@echo "  eks          - Create EKS cluster"
	@echo "  addons       - Install cluster add-ons"
	@echo "  monitoring   - Install monitoring stack"
	@echo "  test         - Run cluster tests"
	@echo "  destroy-eks  - Destroy EKS cluster"
	@echo "  destroy-vpc  - Destroy VPC infrastructure"
	@echo "  clean        - Clean up generated files"
	@echo "  lint         - Run linting checks"

# Infrastructure targets
vpc:
	@echo "Creating VPC infrastructure..."
	./scripts/create-vpc.sh

eks: vpc
	@echo "Creating EKS cluster..."
	./scripts/create-eks.sh

addons:
	@echo "Installing cluster add-ons..."
	./scripts/install-addons.sh

monitoring:
	@echo "Installing monitoring stack..."
	./scripts/install-monitoring.sh

# Testing
test:
	@echo "Running cluster tests..."
	./tests/test-cluster.sh

# Destruction targets
destroy-eks:
	@echo "Destroying EKS cluster..."
	./scripts/destroy-eks.sh

destroy-vpc:
	@echo "Destroying VPC infrastructure..."
	./scripts/delete-vpc.sh

destroy-all: destroy-eks destroy-vpc

# Maintenance targets
clean:
	@echo "Cleaning up generated files..."
	rm -rf artifacts/
	rm -f .env

lint:
	@echo "Running linting checks..."
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not installed"; exit 1; }
	shellcheck scripts/*.sh tests/*.sh
	@command -v yamllint >/dev/null 2>&1 || { echo "yamllint not installed"; exit 1; }
	yamllint manifests/ cloudformation/

# Terraform targets
tf-init:
	cd terraform && terraform init

tf-plan: tf-init
	cd terraform && terraform plan

tf-apply: tf-init
	cd terraform && terraform apply

tf-destroy: tf-init
	cd terraform && terraform destroy

# Development targets
dev-setup:
	@echo "Setting up development environment..."
	@command -v aws >/dev/null 2>&1 || { echo "AWS CLI not installed"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "kubectl not installed"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "helm not installed"; exit 1; }
	chmod +x scripts/*.sh tests/*.sh
	@echo "Development environment ready!"

# Quick deployment
quick-deploy: vpc eks addons test
	@echo "Quick deployment completed!"

# Full deployment with monitoring
full-deploy: vpc eks addons monitoring test
	@echo "Full deployment with monitoring completed!"

# Security targets
security-scan:
	@echo "Running security scans..."
	@command -v trivy >/dev/null 2>&1 || { echo "trivy not installed"; exit 1; }
	trivy fs .
	@command -v cfn-lint >/dev/null 2>&1 || { echo "cfn-lint not installed"; exit 1; }
	cfn-lint cloudformation/*.yaml

validate:
	@echo "Validating configurations..."
	@command -v kubeval >/dev/null 2>&1 || { echo "kubeval not installed"; exit 1; }
	find manifests -name "*.yaml" -exec kubeval {} \;

# Documentation
docs:
	@echo "Generating documentation..."
	@echo "Repository: aws-eks-cluster-awscli"
	@echo "Status: $(shell git status --porcelain | wc -l) uncommitted changes"
	@echo "Last commit: $(shell git log -1 --pretty=format:'%h - %s (%cr)')"

# Git operations
commit-all:
	@echo "Committing all changes..."
	git add .
	git commit -m "chore: automated update $(shell date '+%Y-%m-%d %H:%M:%S')"

push:
	@echo "Pushing to remote..."
	git push origin main

# Complete workflow
ci-cd: lint validate security-scan test
	@echo "CI/CD pipeline completed successfully!"# Updated Sun Nov  9 12:52:14 CET 2025
# Updated Sun Nov  9 12:56:45 CET 2025
