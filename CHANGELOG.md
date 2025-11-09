# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive monitoring stack with Prometheus and Grafana
- Security manifests with network policies and pod security policies
- Terraform alternative for infrastructure deployment
- Automated testing suite for cluster validation
- GitHub Actions workflow for CI/CD
- Makefile for simplified command execution
- Detailed troubleshooting documentation
- Security best practices guide
- Cluster add-ons installation script
- Example application deployments

### Enhanced
- Improved error handling in all scripts
- Better documentation with troubleshooting guide
- Security hardening with proper IAM policies
- Cost optimization recommendations
- Performance monitoring capabilities

### Fixed
- Missing IAM policy file for AWS Load Balancer Controller
- Improved cleanup verification in destroy scripts
- Better error messages and user feedback

## [1.0.0] - 2024-01-XX

### Added
- Initial release with basic EKS cluster deployment
- VPC creation with 3 AZs (public/private subnets)
- EKS cluster with managed node groups
- AWS Load Balancer Controller integration
- OIDC provider setup for IRSA
- Complete cleanup scripts with verification
- Basic documentation and README

### Features
- Multi-AZ VPC infrastructure
- EKS cluster v1.29 support
- Auto-scaling node groups
- Security best practices implementation
- Interactive configuration prompts
