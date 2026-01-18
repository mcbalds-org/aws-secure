# GitHub OIDC Setup for AWS

This Terraform configuration sets up the necessary AWS IAM resources to allow GitHub Actions to authenticate with AWS using OIDC (OpenID Connect).

## What This Creates

1. **IAM OIDC Provider** - Allows GitHub to authenticate with AWS
2. **IAM Role** - Role that GitHub Actions will assume
3. **IAM Policies** - Permissions for the role to manage AWS resources

## Setup Instructions

### Step 1: Get your GitHub repository information

You need:
- GitHub organization or username (e.g., `mcbalds-org`)
- Repository name (e.g., `aws-secure`)

### Step 2: Deploy the OIDC configuration

```bash
cd terraform/github-oidc

# Initialize Terraform
terraform init

# Create a terraform.tfvars file with your GitHub info
cat > terraform.tfvars <<EOF
github_org  = "your-github-username-or-org"
github_repo = "aws-secure"
EOF

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Step 3: Add the role ARN to GitHub Secrets

After the apply completes, Terraform will output the role ARN. Add it to your GitHub repository secrets:

```bash
# Option 1: Using the output command
terraform output -raw github_secret_command | bash

# Option 2: Manually
gh secret set AWS_ROLE_ARN --body 'arn:aws:iam::ACCOUNT_ID:role/github-actions-terraform-role'
```

### Step 4: Verify the setup

```bash
# List your GitHub secrets
gh secret list

# You should see AWS_ROLE_ARN in the list
```

## Security Notes

- The default configuration uses `AdministratorAccess` for simplicity
- For production, replace this with a least-privilege custom policy
- The role can only be assumed by your specific GitHub repository
- No long-lived credentials are stored in GitHub

## Cleanup

To remove the OIDC configuration:

```bash
terraform destroy
```

Note: Only do this if you no longer need GitHub Actions to deploy to AWS.
