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
[![Python](https://img.shields.io/badge/Python-3.8+-blue?logo=python&logoColor=white)](https://www.python.org/)
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

Upon opening the web app the user will be able to pick a number between 1 and 10.
Upon clicking the "Submit" button a JSON payload will be posted to the API backend.

The JSON payload includes several pieces of information, namely

- The number selected by the user
- A timestamp in UTC format
- The geo-location coordinates if the user authorizes

For information on the architecture and deployment of the app refer to
[CONTRIBUTING.md](CONTRIBUTING.md).

## Support

Feel free to open an issue or discussion if you have questions about
contributing.
