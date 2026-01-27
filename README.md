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
All of the componenents are contained in this repo including:

- **Frontend**, a one page web app
- **Backend**, a data ingestion API endpoint
- **Infrastructure-as-Code**, a CloudFormation template that creates the
  necessary AWS infrastructure
- **CI/CD and tooling**, a `devcontainer` configuration, local `pre-commit`
  hooks, and CI/CD workflows

## Usage

1. Ensure AWS CLI is configured with appropriate permissions, if you're using
   the [devcontainer](.devcontainer/devcontainer.json) the environment is ready
   and you just need to `aws login`
2. Run the deployment script:

```bash
cd src/scripts
./deploy.sh
```

The deployment script will output the CloudFront distribution URL. Use this address
on your web browser to open the web app.

Upon opening the web app the user will be able to pick a number between 1 and 10.
By clicking the "Submit" button a JSON payload will be posted to the API backend.

The JSON payload includes:

- The number selected by the user
- A timestamp in UTC format
- The geo-location coordinates if the user authorizes

Check out the [architecture](docs/ARCHITECTURE.md) and how to
[contribute](CONTRIBUTING.md).
When you're done don't forget to tear down the app to avoid unneeded costs.

```bash
cd src/scripts
./destroy.sh
```

## Support

Feel free to open an issue or start a discussion if you have a question or a
feature request.
However please keep in mind support for this project is provided on a
**best effort** basis. The authors do not guarantee or warrant that
its efforts will solve the issue or provide a specific result.
