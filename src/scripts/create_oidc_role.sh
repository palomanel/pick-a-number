#!/bin/bash

# GitHub OIDC role creation Script
# This script creates an IAM role with a trust policy for GH Actions OIDC auth

# Cleanup on exit
trap 'rm -f gh-deploy-iam-*.json' EXIT

# Get the AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "Enabling GitHub OIDC for AWS Account ID: ${AWS_ACCOUNT_ID}"

# Get necessary input from the user
read -p "GitHub organizaton? (GitHub username if it's a personal repo): " -r GH_ORG
read -p "GitHub repository name: " -r GH_REPO
read -p "GitHub environment name (e.g. 'main' or 'prod'): " -r GH_ENV

# Create the OIDC provider for GitHub Actions
aws iam create-open-id-connect-provider \
    --url https://token.actions.githubusercontent.com \
    --client-id-list sts.amazonaws.com

## Set up trust policy document for the role
cat > gh-deploy-iam-trust-policy.json <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:${GH_ORG}/${GH_REPO}:environment:${GH_ENV}"
        }
      }
    }
  ]
}
EOL

## Set up permissions policy document for the role
## TODO: Tighten this up to only allow necessary permissions for deployment
cat > gh-deploy-iam-permissions-policy.json <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowNecessaryPermissionsForGHDeploy",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "dynamodb:*",
        "cloudfront:*",
        "apigateway:*",
        "ce:*",
        "s3:*",
        "budgets:*",
        "lambda:*",
        "iam:*",
        "cloudwatch:*",
        "cloudformation:*",
        "sns:*"
      ],
      "Resource": "*"
    }
  ]
}
EOL

# Set up tags for the role
TAGS=$(cat <<EOL
[
  {
    "Key": "Environment",
    "Value": "${GH_ENV}"
  },
  {
    "Key": "Repository",
    "Value": "https://github.com/${GH_ORG}/${GH_REPO}"
  },
  {
    "Key": "CreatedBy",
    "Value": "GitHub OIDC Deploy Script"
  }
]
EOL
)

# Create the IAM role with a trust policy for GitHub Actions OIDC
aws iam create-role --role-name "gh-deploy-${GH_ENV}-role" \
    --assume-role-policy-document file://gh-deploy-iam-trust-policy.json \
    --tags "$TAGS" \
    --output text

# Attach inline policy
aws iam put-role-policy \
    --role-name "gh-deploy-${GH_ENV}-role" \
    --policy-name gh-deploy-iam-permissions-policy \
    --policy-document file://gh-deploy-iam-permissions-policy.json

# Attach managed policy
aws iam attach-role-policy \
    --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess \
    --role-name "gh-deploy-${GH_ENV}-role"
