#!/bin/bash

# JAMstack Deployment Script
# This script deploys the CloudFormation template and uploads static content

set -e

STACK_NAME="jamstack-app"
TEMPLATE_FILE="jamstack-template.yaml"
FRONTEND_DIR="../frontend"
REGION="eu-central-1"

echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file "${TEMPLATE_FILE}" \
    --stack-name "${STACK_NAME}" \
    --capabilities CAPABILITY_IAM \
    --region "${REGION}"

echo "Getting S3 bucket name..."
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
    --output text)

echo "Uploading static content to S3 bucket: ${BUCKET_NAME}"
aws s3 sync "${FRONTEND_DIR}" "s3://${BUCKET_NAME}" --delete


FUNCTION_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --query 'Stacks[0].Outputs[?OutputKey==`APILambdaName`].OutputValue' \
    --output text)
echo "Updating Lambda function code for ${FUNCTION_NAME}"
cd ../backend
zip -rq lambda_function.zip lambda_function.py
REVISION_ID=$(aws lambda update-function-code \
    --function-name "${FUNCTION_NAME}" \
    --zip-file fileb://lambda_function.zip \
    --query "RevisionId" \
    --output text)
echo "Lambda function code updated successfully, Revision ID: ${REVISION_ID}"
rm lambda_function.zip

echo "Getting CloudFront URL..."
CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontURL`].OutputValue' \
    --output text)

echo "Deployment complete!"
echo "Application URL: ${CLOUDFRONT_URL}"
echo "API Endpoint: ${CLOUDFRONT_URL}/api/data"
