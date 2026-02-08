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

# Get all S3 buckets with the stack name prefix
echo "Finding S3 buckets with prefix: ${STACK_NAME}"
BUCKETS=$(aws s3api list-buckets \
    --query "Buckets[?starts_with(Name, '${STACK_NAME}')].Name" \
    --output text 2>/dev/null || echo "")

# Empty all matching buckets
if [[ -n "${BUCKETS}" ]]; then
    for BUCKET in ${BUCKETS}; do
        echo "Emptying S3 bucket: ${BUCKET}"
        aws s3 rm "s3://${BUCKET}" --recursive --region "${REGION}" || true
    done
else
    echo "No S3 buckets found with prefix: ${STACK_NAME}"
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
