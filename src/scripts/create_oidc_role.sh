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
read -p "App name (the same as configured in you environment): " -r APP_NAME

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

## Create an explicit DENY policy to block privilege escalation
cat > gh-deploy-iam-explicit-deny.json <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyAssumeRole",
      "Effect": "Deny",
      "Action": [
        "sts:AssumeRole",
        "sts:AssumeRoleWithSAML",
        "sts:AssumeRoleWithWebIdentity"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyIAMUserAndKeyOps",
      "Effect": "Deny",
      "Action": [
        "iam:CreateUser",
        "iam:DeleteUser",
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:UpdateUser",
        "iam:CreateLoginProfile",
        "iam:DeleteLoginProfile"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyModifyOtherRoles",
      "Effect": "Deny",
      "Action": [
        "iam:UpdateAssumeRolePolicy",
        "iam:PutRolePolicy",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy"
      ],
      "NotResource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${APP_NAME}-*"
    },
    {
      "Sid": "DenyPassRoleToUnexpectedServices",
      "Effect": "Deny",
      "Action": "iam:PassRole",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "iam:PassedToService": [
            "lambda.amazonaws.com",
            "apigateway.amazonaws.com"
          ]
        }
      }
    }
  ]
}
EOL

# Allow CloudFormation to create and manage the project's IAM resources
# (roles and managed policies, scoped to predictable names)
cat > gh-deploy-iam-allow-project-resources.json <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCreateAndManageProjectRoles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PassRole",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:UpdateAssumeRolePolicy"
      ],
      "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${APP_NAME}-*"
    },
    {
      "Sid": "AllowCreateAndManageProjectManagedPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:ListPolicyVersions",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:GetPolicyVersion",
        "iam:SetDefaultPolicyVersion",
        "iam:TagPolicy",
        "iam:UntagPolicy",
        "iam:ListPolicies"
      ],
      "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${APP_NAME}-*"
    }
  ]
}
EOL

# Create the IAM role with a trust policy for GitHub Actions OIDC
aws iam create-role --role-name "gh-deploy-${GH_ENV}-role" \
    --assume-role-policy-document file://gh-deploy-iam-trust-policy.json \
    --tags "$TAGS" \
    --output text

# Attach managed policy
# PowerUserAccess: Grants full access to services and resources,
# but does not allow management of users and groups
aws iam attach-role-policy \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess \
    --role-name "gh-deploy-${GH_ENV}-role"

# Attach the explicit deny inline policy (deny overrides allow)
aws iam put-role-policy \
    --role-name "gh-deploy-${GH_ENV}-role" \
    --policy-name gh-deploy-iam-explicit-deny \
    --policy-document file://gh-deploy-iam-explicit-deny.json

# Attach allow policy so CloudFormation can create and manage project IAM resources
aws iam put-role-policy \
    --role-name "gh-deploy-${GH_ENV}-role" \
    --policy-name gh-deploy-iam-allow-project-resources \
    --policy-document file://gh-deploy-iam-allow-project-resources.json
