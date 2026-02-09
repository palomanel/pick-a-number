# JAMstack Application Architecture on AWS

## Overview

This architecture implements a JAMstack (JavaScript, APIs, Markup) application
on AWS, providing a scalable, serverless solution where static content and APIs
are accessible from the same domain using different URI patterns.

The main objectives when designing this architecture have been:

1. provide a full working app example with a frontend, data storage, and
   data retrieval and analysis
2. leverage the AWS free tier to create and run the app without incurring any
   costs
3. apply best practices whenever possible, objective 2 entails avoiding some
   services and patterns, this is discussed below

![JAMstack Architecture](assets/jamstack-architecture.png)

## Key Features

- **Reliable**: Multi-AZ deployment with AWS serverless managed services,
  providing auto-scaling and high availability with minimal operational
  overhead.
- **Secure**: Unified access through CloudFront routing, edge locations
  worldwide cache content close to the user and provide DDoS protection.
  Network isolation and IAM protect backend services.
- **Auditable**: Log forwarding and retention for all system components.
- **Cost efficient**: Pay-per-use pricing model for all services, with
  budget notifications for ongoing cost control.

## Architecture Components

### Frontend Layer

- **Amazon CloudFront**: [CDN](https://aws.amazon.com/cloudfront/) for global
  content delivery and request routing, [AWS WAF](https://aws.amazon.com/waf/)
  is not available from the free tier but should be in place for a production-
  ready architecture.
- **Amazon S3**: Very cost efficient storage to host static assets (HTML, CSS,
  JavaScript bundles). Versioning is enabled as it protects against accidental
  deletions and malicious modifications.

### API Layer

- **Amazon API Gateway**: manages the RESTful API endpoints under `/api/*`
  path.
- **AWS Lambda**: Serverless functions for JSON payload processing, Lambda
  was used for simplicity, on a real app the compute could be replaced for
  another pay-as-you-go resource like ECS Fargate.

### Data Layer

- **Amazon DynamoDB**: NoSQL database for JSON data storage. For the example
  use-case we would ideally would use Timestream which is designed for
  time-series workloads, but its free tier is only available for 30 days.
  Using DynamoDB has the downside of the caller code needing to aggregate the
  data when doing a range query.

### Management Layer

- **Logging**:
  - **Amazon S3** and **CloudFront** logs can be only delivered to S3,
    a "logs" bucket was added for this purpose together with a lifecycle policy
    with the desired retention period. Typically in a production system these
    events will be forwarded to a
    [SIEM](https://en.wikipedia.org/wiki/Security_information_and_event_management)
    system.
  - **Application** level logs that need real-time monitoring
    (API Gateway and Lambda) are delivered to Cloudwatch, the same retention
    period is applied.
- **Backups**:
  - **~~DynamoDB Point-in-Time Recovery (PITR)~~** is not included in the AWS
    Free Tier and incurs additional charges so it's not part of the
    architecture. Possible alternatives would be manually creating backups
    or automating on a schedule using EventBridge + Lambda. No other component
    needs backups as everything else can be restored from source.

## Request Flow

1. **Static Content**: `/` → CloudFront → S3
1. **API Requests**: `/api/*` → CloudFront → API Gateway → Lambda → DynamoDB
   1. `POST /api/submit-number`, handled by the `SubmitNumberFunction` Lambda,
      accepts a paylod that is persisted in DynamoDB.
   1. `GET /api/daily-stats`, handled by the `DailyStatsFunction` Lambda,
      scans DynamoDB for a date range and returns statistics.
