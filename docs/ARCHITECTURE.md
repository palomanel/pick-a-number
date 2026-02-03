# JAMstack Application Architecture on AWS

## Overview

This architecture implements a JAMstack (JavaScript, APIs, Markup) application
on AWS, providing a scalable, serverless solution where static content and APIs
are accessible from the same domain using different URI patterns.

![JAMstack Architecture](assets/jamstack-architecture.png)

## Architecture Components

### Frontend Layer

- **Amazon S3**: Hosts static assets (HTML, CSS, JavaScript bundles)
- **Amazon CloudFront**: CDN for global content delivery and request routing

### API Layer

- **Amazon API Gateway**: RESTful API endpoints under `/api/*` path
- **AWS Lambda**: Serverless functions for JSON payload processing

### Data Layer

- **Amazon DynamoDB**: NoSQL database for JSON data storage

## Request Flow

1. **Static Content**: `/` → CloudFront → S3
1. **API Requests**: `/api/*` → CloudFront → API Gateway → Lambda → DynamoDB
   1. `POST /api/submit-number`, handled by the `SubmitNumberFunction` Lambda,
      accepts a paylod that is persisted in DynamoDB.
   1. `GET /api/daily-stats`, handled by the `DailyStatsFunction` Lambda,
      scans DynamoDB and returns daily statistics

## Key Features

- **Single Domain**: Unified access through CloudFront routing
- **Serverless**: Minimal operational overhead and Multi-AZ deployment with AWS
  managed services
- **Auto-scaling**: Handles traffic spikes automatically
- **Global CDN**: CloudFront edge locations worldwide cache content close
  to the user and provide DDoS protection
- **Reliability**: Multi-AZ deployment with AWS managed services
- **FinOps optimized**: Pay-per-use pricing model and budget notifications
