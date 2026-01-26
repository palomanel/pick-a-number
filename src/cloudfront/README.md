# JAMstack CloudFormation Deployment

This directory contains the CloudFormation template and deployment scripts for
the JAMstack application architecture.

## Files

- `jamstack-template.yaml` - CloudFormation template
- `deploy.sh` - Deployment script
- `README.md` - This file

## Architecture Components

The template creates:

- **S3 Bucket** - Static content hosting
- **CloudFront Distribution** - CDN with routing rules
- **API Gateway** - RESTful API endpoints
- **Lambda Function** - JSON processing
- **DynamoDB Table** - Data storage
- **IAM Roles** - Secure access permissions

## Deployment

1. Ensure AWS CLI is configured with appropriate permissions
2. Run the deployment script:

```bash
./deploy.sh
```

## Manual Deployment

```bash
# Deploy CloudFormation stack
aws cloudformation deploy \
    --template-file jamstack-template.yaml \
    --stack-name jamstack-app \
    --capabilities CAPABILITY_IAM \
    --region us-east-1

# Upload static content
aws s3 sync ../frontend s3://BUCKET_NAME --delete
```

## Outputs

- **CloudFrontURL** - Application access URL
- **S3BucketName** - Static content bucket
- **ApiEndpoint** - API endpoint URL

## Request Routing

- `/` → S3 static content
- `/api/*` → API Gateway → Lambda → DynamoDB
