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

A sample **JAMstack** app. More details about the architecture are provided
in [ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Overview

This project contains the code for a basic
[JAMstack](https://en.wikipedia.org/wiki/JAMstack) app.
All of the components are contained in this repo including:

- **Frontend**, a one page web app using HTML and vanilla JavaScript
- **Backend**, a data ingestion API endpoint and persistence layer
- **Infrastructure-as-Code**, a CloudFormation template that deploys the
  AWS infrastructure, including an AWS Budget
- **CI/CD and tooling**, a `devcontainer` configuration, local `pre-commit`
  hooks, and CI/CD workflows

If you have an [AWS Free Tier](https://aws.amazon.com/free/) account and don't
exceed the thresholds for the services being used your consumption
will be **zero**, so this project is a great way to get your feet wet using
cloud infrastructure.

## Usage

Everything has been built and tested inside the
[devcontainer](.devcontainer/devcontainer.json) using
[VS Code](https://code.visualstudio.com/),
if you plan to deploy from you local system there's a couple pre-requisites to
consider:

- scripts need a Linux or MacOS enviroment
- [aws-cli](https://aws.amazon.com/cli/) should be available
- you should have administrator access to an AWS account

To deploy the app follow these steps:

1. Clone or fork the project
1. Login to your AWS account, `aws login` with web based authentication works
   fine, no need to use tokens
1. Review `src/scripts/deploy.sh` and change the variable defaults to your
   liking (i.e. `STACK_NAME`, `REGION`, `BUDGET_EMAIL`)
1. Run the deployment script:

```bash
cd src/scripts
./deploy.sh
```

The deployment script will output the CloudFront distribution URL. Use this address
on your web browser to open the web app.

Upon opening the web app users will be able to pick a number between 1 and 10.
By clicking the "Submit" button a JSON payload will be posted to the API backend
and stored in DynamoDB. The web browser will require authorization to access the
user's location. This is optional.

The JSON payload includes:

- The number selected by the user
- A timestamp in UTC format
- The geo-location coordinates if the user authorizes

Review the
[AWS Billing and Cost Management Console](https://aws.amazon.com/aws-cost-management/billing-and-cost-management-console-home/)
to understand the infrastructure cost. Navigate to the **Free Tier**
screen to learn more about usage thresholds for each service.
When you're done don't forget to tear down everything to avoid unneeded costs.

```bash
cd src/scripts
./destroy.sh
```

Check out the [architecture](docs/ARCHITECTURE.md) and how to
[contribute](CONTRIBUTING.md).
