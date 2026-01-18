terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Variables
variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

# Create the GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}

# Create IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "github-actions-terraform"
  }
}

# Attach AdministratorAccess policy (adjust permissions based on your needs)
# For production, you should create a custom policy with least privilege
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Alternatively, create a custom policy with specific permissions
# Uncomment this and comment out the AdministratorAccess attachment above
# resource "aws_iam_role_policy" "github_actions_terraform" {
#   name = "terraform-permissions"
#   role = aws_iam_role.github_actions.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:*",
#           "eks:*",
#           "iam:*",
#           "s3:*",
#           "dynamodb:*",
#           "logs:*",
#           "kms:*"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# Outputs
output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role - Add this to GitHub Secrets as AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

output "github_secret_command" {
  description = "Command to add the role ARN to GitHub secrets"
  value       = "gh secret set AWS_ROLE_ARN --body '${aws_iam_role.github_actions.arn}'"
}
