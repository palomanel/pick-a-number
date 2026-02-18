#!/bin/bash

# JAMstack Deployment Script
# This script deploys all the app components:
# infrastructure, frontend, and backend

# exit immediately if a command exits with a non-zero status
set -e

# Cleanup on exit
trap 'rm -rf ../backend/dist 2>/dev/null' EXIT

# Load environment variables or fallback to defaults
BUDGET_EMAIL="${BUDGET_EMAIL:-john_doe@example.com}"
APP_NAME="${APP_NAME:-pick-a-number}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
AWS_REGION="${REGION:-eu-central-1}"

# Source location
TEMPLATE_FILE="../cloudformation/jamstack-template.yaml"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"

echo "Activating cost allocation tags in Billing Console..."
aws ce update-cost-allocation-tags-status \
    --cost-allocation-tags-status="TagKey='aws:cloudformation:stack-name',Status=Active" \
    --output text

STACK_NAME="${APP_NAME}-${ENVIRONMENT}"
echo "Deploying CloudFormation stack: ${STACK_NAME}"
aws cloudformation deploy \
    --template-file "${TEMPLATE_FILE}" \
    --stack-name "${STACK_NAME}" \
    --capabilities CAPABILITY_IAM \
    --region "${AWS_REGION}" \
    --parameter-overrides BudgetNotificationEmail="${BUDGET_EMAIL}" Environment="${ENVIRONMENT}" \
    --tags Environment="${ENVIRONMENT}"

echo "Getting S3 bucket name..."
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${AWS_REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
    --output text)

echo "Uploading static content to S3 bucket: ${BUCKET_NAME}"
aws s3 sync "../${FRONTEND_DIR}" "s3://${BUCKET_NAME}" --delete

cd ../backend
echo "Creating Lambda layer for Python dependencies..."
mkdir -p dist/python
pip install -r requirements.txt -t dist/python --quiet --disable-pip-version-check
cd dist
zip -rq dependencies-layer.zip python
LAYER_ARN=$(aws lambda publish-layer-version \
    --layer-name "${STACK_NAME}-dependencies" \
    --description "Python dependencies for ${STACK_NAME}" \
    --zip-file fileb://dependencies-layer.zip \
    --compatible-runtimes python3.14 \
    --region "${AWS_REGION}" \
    --query "LayerVersionArn" \
    --output text)

echo "Layer published: ${LAYER_ARN}"
cd ..

echo "Packaging and deploying backend Lambda functions..."
while read FUNCTION SOURCE; do
    FUNCTION_NAME=$(aws cloudformation describe-stacks \
        --stack-name "${STACK_NAME}" \
        --query "Stacks[0].Outputs[?OutputKey==\`${FUNCTION}\`].OutputValue" \
        --output text)

    # Attach layer first (idempotent - safe to run every time)
    echo "Attaching layer to ${FUNCTION_NAME}"
    aws lambda update-function-configuration \
        --function-name "${FUNCTION_NAME}" \
        --layers "${LAYER_ARN}" \
        --region "${AWS_REGION}" \
        --output text > /dev/null

    aws lambda wait function-updated --function-name "${FUNCTION_NAME}" --region "${AWS_REGION}"

    # Now update code
    echo "Updating Lambda function code for ${FUNCTION_NAME}"
    zip -rq "dist/${FUNCTION}.zip" "${SOURCE}"
    REVISION_ID=$(aws lambda update-function-code \
        --function-name "${FUNCTION_NAME}" \
        --zip-file fileb://dist/"${FUNCTION}.zip" \
        --query "RevisionId" \
        --output text)
    echo "Lambda function ${FUNCTION_NAME} updated successfully, Revision ID: ${REVISION_ID}"
done << EOF
SubmitNumberFunctionName submit_number.py
StatsFunctionName stats.py
EOF

echo "Getting CloudFront URL..."
CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${AWS_REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontURL`].OutputValue' \
    --output text)

cat << EOF
Deployment complete!
Application URL:
- ${CLOUDFRONT_URL}
API Endpoints:
- ${CLOUDFRONT_URL}/api/submit-number
- ${CLOUDFRONT_URL}/api/stats
EOF
