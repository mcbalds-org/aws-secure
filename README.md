\# Secure EKS Deployment with Terraform



A production-ready, security-hardened AWS EKS cluster deployment using Infrastructure as Code (IaC) best practices.



\## 🏗️ Architecture



\- \*\*Cloud Provider\*\*: AWS

\- \*\*Container Orchestration\*\*: Amazon EKS (Kubernetes)

\- \*\*Infrastructure as Code\*\*: Terraform

\- \*\*CI/CD\*\*: GitHub Actions

\- \*\*Security\*\*: DevSecOps practices with automated scanning



\## 🔒 Security Features



\- ✅ Encrypted EKS secrets using AWS KMS

\- ✅ Private worker nodes in isolated subnets

\- ✅ VPC Flow Logs for network monitoring

\- ✅ IMDSv2 enforced on EC2 instances

\- ✅ EBS volume encryption

\- ✅ Control plane audit logging

\- ✅ IAM Roles for Service Accounts (IRSA)

\- ✅ Automated security scanning in CI/CD

\- ✅ Network policies and security groups



\## 📋 Prerequisites



\- \[Terraform](https://www.terraform.io/downloads) >= 1.0

\- \[AWS CLI](https://aws.amazon.com/cli/) configured with credentials

\- \[kubectl](https://kubernetes.io/docs/tasks/tools/)

\- AWS account with appropriate permissions



\## 🚀 Quick Start



\### 1. Clone the repository

```bash

git clone https://github.com/mcbalds-org/aws-secure.git

cd aws-secure

```



\### 2. Configure backend

Create S3 bucket and DynamoDB table for Terraform state:

```bash

aws s3 mb s3://your-terraform-state-bucket

aws s3api put-bucket-versioning --bucket your-terraform-state-bucket --versioning-configuration Status=Enabled

aws dynamodb create-table --table-name terraform-state-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY\_PER\_REQUEST

```



\### 3. Initialize Terraform

```bash

cd terraform/environments/dev

terraform init

```



\### 4. Review the plan

```bash

terraform plan

```



\### 5. Deploy infrastructure

```bash

terraform apply

```



\### 6. Configure kubectl

```bash

aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

kubectl get nodes

```



\## 🛡️ Security Scanning



This project uses automated security scanning:



\- \*\*Terraform\*\*: `tfsec`, `checkov`

\- \*\*Containers\*\*: `trivy`

\- \*\*Secrets\*\*: `gitleaks`

\- \*\*Dependencies\*\*: `dependabot`



\## 📁 Project Structure



```

├── .github/workflows/    # CI/CD pipelines

├── terraform/           # Terraform configurations

│   ├── environments/    # Environment-specific configs

│   └── modules/        # Reusable Terraform modules

├── kubernetes/         # Kubernetes manifests

└── docs/              # Documentation

```



\## 💰 Cost Estimate



Running this infrastructure 24/7:

\- EKS Control Plane: ~$73/month

\- Worker Nodes (2x t3.medium): ~$60/month

\- NAT Gateway: ~$32/month

\- \*\*Total\*\*: ~$165/month



\## 🧹 Cleanup



To destroy all resources and avoid charges:

```bash

terraform destroy

```



\## 📚 Documentation



\- \[Architecture Details](docs/ARCHITECTURE.md)

\- \[Deployment Guide](docs/DEPLOYMENT.md)

\- \[Security Practices](docs/SECURITY.md)



\## 🤝 Contributing



1\. Fork the repository

2\. Create a feature branch

3\. Make your changes

4\. Run security scans locally

5\. Submit a pull request



\## 📄 License



MIT License - see LICENSE file for details



\## 🔗 Resources



\- \[AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

\- \[Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

\- \[Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
\- \[Complete Deployment Guide](DEPLOYMENT.md)
