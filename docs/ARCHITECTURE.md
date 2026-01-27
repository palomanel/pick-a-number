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

1. **Static Content**: `example.com/` → CloudFront → S3
2. **API Requests**: `example.com/api/*` → CloudFront → API Gateway → Lambda → DynamoDB

## Key Features

- **Single Domain**: Unified access through CloudFront routing
- **Serverless**: Minimal operational overhead for Multi-AZ deployment with AWS
  managed services, and Pay-per-use pricing model
- **Auto-scaling**: Handles traffic spikes automatically
- **Global CDN**: CloudFront edge locations worldwide cache content close
  to the user and provide DDoS protection
- **Reliability**: Multi-AZ deployment with AWS managed services
