#!/bin/bash

# JAMstack Destruction Script
# This script forcefully deletes the CloudFormation stack and all associated resources

set -e

STACK_NAME="jamstack-app"
REGION="eu-central-1"

echo "WARNING: This will delete all resources in stack '${STACK_NAME}' including data in S3 and DynamoDB!"
read -p "Are you sure you want to continue? (yes/no): " -r CONFIRM

if [[ "${CONFIRM}" != "yes" ]]; then
    echo "Destruction cancelled."
    exit 0
fi

echo "Starting destruction of stack: ${STACK_NAME}"

# Get the S3 bucket name
echo "Retrieving S3 bucket name..."
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
    --output text 2>/dev/null || echo "")

# Empty the S3 bucket if it exists (required before deletion)
if [[ -n "${BUCKET_NAME}" ]]; then
    echo "Emptying S3 bucket: ${BUCKET_NAME}"
    aws s3 rm "s3://${BUCKET_NAME}" --recursive --region "${REGION}" || true
fi

# Delete the CloudFormation stack
echo "Deleting CloudFormation stack: ${STACK_NAME}"
aws cloudformation delete-stack \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}"

# Wait for stack deletion to complete
echo "Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" 2>/dev/null || true

echo "Stack deletion initiated."
echo "Destruction complete!"
echo ""
echo "Note: Some resources may take additional time to fully delete."
echo "To check deletion status, run:"
echo "  aws cloudformation describe-stacks --stack-name ${STACK_NAME} --region ${REGION}"
