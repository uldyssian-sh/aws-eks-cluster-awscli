#!/bin/bash
set -e

# Manual discussion creation script
echo "Manual Discussion Creation Required"
echo "=================================="
echo ""
echo "GitHub API doesn't allow automated discussion creation."
echo "Please create discussions manually using these URLs:"
echo ""

repos=(
  "aws-eks-cluster-awscli"
  "aws-eks-k8s-terraform" 
  "aws-eks-cluster-kasten"
  "enterprise-eks-multi-az-cluster"
  "terraform-provider-vcf"
  "vmware-vsphere-8-learn"
  "vmware-vsphere-7-learn"
  "vmware-vsan-8-learn"
  "vmware-aria-suite-8-learn"
  "vmware-power-cli-all"
  "vmware-cis-vm"
  "vmware-cis-vsphere8-audit"
  "vmware-sec-assessment"
  "vmware-vm-audit-dod-stig"
  "github-stats"
  "vcf-security-and-compliance-guidelines"
  "validated-solutions-for-cloud-foundation"
  "power-validated-solutions-for-cloud-foundation"
  "vmware-vsan-health"
  "vmware-bc-product-icons"
  "vmware-pptx-iconography"
)

for repo in "${repos[@]}"; do
  echo "Repository: "$repo""
  echo "URL: https://github.com/uldyssian-sh/"$repo"/discussions/new"
  echo "Copy content from all_discussions.md for this repository"
  echo "---"
done

echo ""
echo "Total: ${#repos[@]} repositories need discussions"
echo "Content available in: all_discussions.md"