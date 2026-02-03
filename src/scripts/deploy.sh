#!/bin/bash

# JAMstack Deployment Script
# This script deploys all the app components:
# infrastructure, frontend, and backend

set -e

TEMPLATE_FILE="../cloudformation/jamstack-template.yaml"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"
BUDGET_EMAIL="john_doe@example.com"
STACK_NAME="jamstack-app"
REGION="eu-central-1"

echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file "${TEMPLATE_FILE}" \
    --stack-name "${STACK_NAME}" \
    --capabilities CAPABILITY_IAM \
    --region "${REGION}" \
    --parameter-overrides BudgetNotificationEmail="${BUDGET_EMAIL}"

echo "Getting S3 bucket name..."
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
    --output text)

echo "Uploading static content to S3 bucket: ${BUCKET_NAME}"
aws s3 sync "../${FRONTEND_DIR}" "s3://${BUCKET_NAME}" --delete

FUNCTION_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --query 'Stacks[0].Outputs[?OutputKey==`SubmitNumberFunctionName`].OutputValue' \
    --output text)
echo "Updating Lambda function code for ${FUNCTION_NAME}"
cd ../backend
zip -rq submit_number.zip submit_number.py
REVISION_ID=$(aws lambda update-function-code \
    --function-name "${FUNCTION_NAME}" \
    --zip-file fileb://submit_number.zip \
    --query "RevisionId" \
    --output text)
echo "Lambda function ${FUNCTION_NAME} updated successfully, Revision ID: ${REVISION_ID}"
rm submit_number.zip

echo "Getting CloudFront URL..."
CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontURL`].OutputValue' \
    --output text)

echo "Deployment complete!"
echo "Application URL: ${CLOUDFRONT_URL}"
echo "API Endpoint: ${CLOUDFRONT_URL}/api/submit-number"
