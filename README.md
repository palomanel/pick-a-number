# Pick a Number

[![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![CloudFormation](https://img.shields.io/badge/CloudFormation-IaC-ff9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/cloudformation/)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Docker](https://img.shields.io/badge/Docker-Devcontainer-blue?logo=docker&logoColor=white)](https://www.docker.com/)
[![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=000)](https://www.javascript.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/palomanel/pick-a-number)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier)
[![Python](https://img.shields.io/badge/Python-3.14+-blue?logo=python&logoColor=white)](https://www.python.org/)
[![SemVer](https://img.shields.io/badge/SemVer-2.0.0-blue.svg)](https://semver.org/)

A sample **JAMstack** app, read more about the project's objectives and design
decisions in the [architecture documentation](docs/ARCHITECTURE.md).

## Overview

This project contains the code for a basic
[JAMstack](https://en.wikipedia.org/wiki/JAMstack) app.
All of the components are contained in this repo including:

- **Frontend**, a one page web app using HTML and vanilla JavaScript
- **Backend**, a data ingestion REST API and persistence layer
- **Management**, supports several environments with independent budget tracking
  , logging for all components, X-ray tracing, Service Level Objectives alarms
  and dashboard
- **Infrastructure-as-Code**, a CloudFormation template that deploys the
  AWS infrastructure, deployment is done through a GitHub action using OIDC
  trust and following the principle of least privilege, no tokens used
- **CI/CD and tooling**, a `devcontainer` configuration, `pre-commit`
  hooks, unit tests

If you have an [AWS Free Tier](https://aws.amazon.com/free/) account and don't
exceed resource thresholds your consumption will be **zero**, so this
project is a great way to get your feet wet using AWS cloud infrastructure.

## Usage

### Pre-requisites

Everything has been built and tested inside the
[devcontainer](.devcontainer/devcontainer.json) using
[VS Code](https://code.visualstudio.com/).

Mileage may vary when using an ad-hoc environment, keep in mind
there's a few pre-requisites to consider:

- python 3.14
- shell scripts need a Linux or MacOS environment
- [aws-cli](https://aws.amazon.com/cli/)
- administrator access to an AWS account

### Testing locally

It's possible to test backend python services locally by using
[moto](https://github.com/getmoto/moto)
to mock out AWS infrastructure.

Create a virtual environment, install dependencies and run
unit tests:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r src/backend/requirements.txt -r tests/requirements-test.txt
pytest tests/ -v
```

There's also a GitHub workflow that runs tests for any pull request to `main`.

### Deploying from the CLI

To deploy the app follow these steps:

1. Clone or fork the project
1. Login to your AWS account, `aws login` with web based authentication works
   fine, no need to use tokens
1. Review `src/scripts/deploy.sh` and set environment variables to your
   liking, it's particularly important you set `APP_NAME` and `ENVIRONMENT`
   to avoid name clashes in AWS resources
1. Run the deployment script:

```bash
cd src/scripts
APP_NAME=my-test ./deploy.sh
```

The deployment script will output the application endpoint, all traffic is
fronted by the CloudFront distribution URL.

### Continuous deployment using GitHub Actions

The first step is to
[fork the repository](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo).

The `deploy` workflow uses OIDC to assume a deployment role, check
[GitHub changelog: GitHub Actions: Secure cloud deployments with OpenID Connect](https://github.blog/changelog/2021-10-27-github-actions-secure-cloud-deployments-with-openid-connect/)
for more details. This auth method is both more practical and more secure,
no need to create IAM accounts or generate and store tokens.

Only a GitHub Actions runner triggered for an environment in your repo
will be able to acquire the AWS deploy role.
You'll need to setup the trust relationship. Summarizing the necessary steps:

1. Create an AWS IAM Identity Provider that trusts
   GitHub's OIDC endpoint to enable federation.
2. Create the actual role that the GitHub action runner will assume,
   specifying a trust relationship with a specific repo.
3. Configure the GitHub runner to use the role.

The first couple of steps can be done with a script shipped with this repo.
Ensure you're logged into you AWS account before starting,
The script is interactive and will guide you through the process.

```bash
cd src/scripts
./create_oidc_role.sh
```

Note down the OIDC role's ARN, you'll need that in the next step.

Access your repo settings and add configure the `main`
[GitHub environment](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
, add the following values:

- environment variables, accessible for workflows under the `vars` context.
  - `APP_NAME`
  - `AWS_REGION`
  - `NOTIFY_EMAIL`
  - `ENVIRONMENT`
- secrets, accessible for workflows under the `secrets` context.
  - `AWS_ROLE_ARN`

When triggered the `deploy` job will execute `deploy.sh`.
After successful completion the app will be deployed and the
application endpoint will added to the GitHub environment.

If you have problems with the deployment make sure all of the parameters
you provided for the creation of the OIDC role are correct.

### Using the app

The web app prompts users to pick a number between 1 and 10.
By clicking the "Submit" button a JSON payload will be posted to the API backend
and stored in DynamoDB. The web browser will require authorization to access the
user's location, this is optional.

You can connect to the REST API using `curl`:

```bash
# submit a new record
curl -s -X POST "https://example.cloudfront.net/api/submit-number" \
  -H "Content-Type: application/json" \
  -d '{
    "number": 7,
    "timestamp": "2026-02-05T16:29:01.959Z",
    "location": null
  }' | jq .
# query submitted records
# the key is the record submission date ("event_date")
curl -s "https://example.cloudfront.net/api/stats" \
  -G \
  --data-urlencode "from=2026-01-01" \
  --data-urlencode "to=2026-02-28" \
  | jq .
```

Review the
[AWS Billing and Cost Management Console](https://aws.amazon.com/aws-cost-management/billing-and-cost-management-console-home/)
to understand the infrastructure cost. Navigate to the **Free Tier**
screen to learn more about usage thresholds for each service.

For more details check the
[architecture](docs/ARCHITECTURE.md) and how to
[contribute](CONTRIBUTING.md).
When you're done don't forget to tear down everything to avoid unneeded costs.

```bash
cd src/scripts
./destroy.sh
```
