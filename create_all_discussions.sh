#!/bin/bash
echo "GitHub Discussion Creation URLs:"
echo "================================"

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
  echo "https://github.com/uldyssian-sh/$repo/discussions/new"
done

echo ""
echo "Copy discussions from all_discussions.md file"
echo "Each repository has 2 thematic Q&A discussions ready to paste"
