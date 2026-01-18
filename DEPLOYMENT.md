# Deployment Guide

This guide provides step-by-step instructions to deploy the EKS infrastructure from scratch.

## Prerequisites

Before deploying, ensure you have:

- [x] AWS CLI installed and configured with valid credentials
- [x] Terraform >= 1.0 installed
- [x] GitHub CLI (`gh`) installed and authenticated
- [x] Git installed
- [x] AWS account with appropriate permissions

## Quick Start - Deploy Everything

### Step 1: Set up Terraform State Backend (One-time setup)

The Terraform state backend stores your infrastructure state securely in AWS.

```bash
# Create S3 bucket for state
aws s3 mb s3://amcel-terraform-state-2025

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket amcel-terraform-state-2025 \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**Note:** Only run this once. These resources persist across deployments.

### Step 2: Set up GitHub Actions OIDC (One-time setup)

This allows GitHub Actions to securely deploy to AWS without storing credentials.

```bash
cd terraform/github-oidc
terraform init
terraform apply
```

When prompted, review the plan and type `yes` to confirm.

After apply completes, add the IAM role to GitHub secrets:

```bash
# Terraform outputs this command for you
terraform output -raw github_secret_command | bash
```

Verify the secret was added:

```bash
gh secret list
# Should show: AWS_ROLE_ARN
```

### Step 3: Deploy EKS Infrastructure

**Option A: Deploy via GitHub Actions (Recommended)**

```bash
# From the project root
gh workflow run terraform-deploy.yml

# Monitor the deployment
gh run watch
```

The deployment takes approximately 12-15 minutes.

**Option B: Deploy Locally**

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### Step 4: Configure kubectl (After deployment)

```bash
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Verify cluster access
kubectl get nodes
```

## Tear Down / Cleanup

### Destroy EKS Infrastructure

**Option A: Via GitHub Actions**

```bash
gh workflow run terraform-destroy.yml \
  -f environment=dev \
  -f confirm_destroy=destroy

# Monitor the destroy process
gh run watch
```

**Option B: Locally**

```bash
cd terraform/environments/dev
terraform destroy
```

### Destroy GitHub OIDC (Optional - only if you won't deploy again)

```bash
cd terraform/github-oidc
terraform destroy

# Remove the GitHub secret
gh secret delete AWS_ROLE_ARN
```

### Destroy State Backend (Optional - only if completely done)

```bash
# Delete S3 bucket (must be empty first)
aws s3 rm s3://amcel-terraform-state-2025 --recursive
aws s3 rb s3://amcel-terraform-state-2025

# Delete DynamoDB table
aws dynamodb delete-table \
  --table-name terraform-state-lock \
  --region us-east-1
```

## Cost Information

Running this infrastructure 24/7 costs approximately:
- EKS Control Plane: ~$73/month
- Worker Nodes (2x t3.medium): ~$60/month
- NAT Gateway: ~$32/month
- **Total: ~$165/month**

State backend resources (S3 + DynamoDB) cost ~$0-1/month.

## Troubleshooting

### "AWS_ROLE_ARN secret not found"

The GitHub OIDC role hasn't been set up. Run Step 2 above.

### "Backend configuration changed"

Run `terraform init -reconfigure` in the relevant directory.

### "EKS version not supported"

Update the `version` parameter in `terraform/environments/dev/main.tf` to a currently supported version (check AWS EKS documentation).

### Deployment fails with permissions error

Ensure the GitHub OIDC IAM role has the necessary permissions. The least-privilege policy is defined in `terraform/github-oidc/main.tf`.

## CI/CD Workflow Overview

The project includes three GitHub Actions workflows:

1. **terraform-security.yml** - Runs on every PR and push
   - Security scanning (tfsec, Checkov, Trivy, Gitleaks)
   - Terraform validation
   - Comments PR with scan results

2. **terraform-deploy.yml** - Manual deployment
   - Trigger: `gh workflow run terraform-deploy.yml`
   - Deploys infrastructure to AWS
   - Provides deployment summary

3. **terraform-destroy.yml** - Manual destruction
   - Trigger: `gh workflow run terraform-destroy.yml -f environment=dev -f confirm_destroy=destroy`
   - Requires typing "destroy" to confirm
   - Safely tears down infrastructure

## Security Features

- ✅ Least-privilege IAM policies (no AdministratorAccess)
- ✅ OIDC authentication (no long-lived AWS credentials)
- ✅ Automated security scanning in CI/CD
- ✅ Encrypted Terraform state in S3
- ✅ State locking via DynamoDB
- ✅ Private worker nodes
- ✅ Network segmentation (public/private subnets)

## Next Steps After Deployment

1. Configure kubectl access (see Step 4)
2. Deploy applications to your cluster
3. Set up monitoring and logging
4. Configure cluster autoscaling
5. Deploy ingress controller

## Quick Reference Commands

```bash
# Check infrastructure status
cd terraform/environments/dev
terraform show

# List GitHub workflow runs
gh run list

# View cluster info
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
```
