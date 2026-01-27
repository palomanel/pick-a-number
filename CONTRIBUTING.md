# How to contribute

Thank you for your interest in contributing! This document provides guidelines
and instructions for contributing to this project.

## Getting Started

Follow these steps:

1. Fork the repository and/or create a local clone
2. Open the project in VS Code and select `Reopen in Container`
3. Follow the guidance below to create and submit a PR

## Project Structure

```text
.
├── .github/                # GitHub specific settings
│   └── workflows/          # CI/CD jobs
├── .devcontainer/          # Devcontainer configuration
├── docs/                   # Documentation
├── cloudformation/         # Infrastructure as Code
├── src/                    # Application source code
│   └── backend/            # Application Backend
│   └── cloudformation/     # Infrastructure as Code
│   └── frontend/           # Application Frontend
│   └── scripts/            # Utility scripts used for CI/CD and locally
├── tests/                  # Test suite
├── README.md               # Repository information
├── LICENSE                 # MIT License
└── CONTRIBUTING.md         # Contribution instructions
```

## Development guidelines

- Repository
  - Use [Conventional Commits](https://www.conventionalcommits.org),
    this provides a clear structure to commit
    history and enables automated changelog generation.
  - Use [Semantic Versionionig](https://semver.org/) for release tags,
    under this scheme, version numbers and the way they change convey
    meaning about the underlying code and what has been modified from
    one version to the next.
- General development
  - Use meaningful variable and function names
  - Add docstrings to functions and classes
  - Keep functions focused and modular
  - Write comments for complex logic
- Javascript
  - Use vanilla Javascript only
  - No `let` declarations, all data structures should be declared as `const`
- Python
  - Follow PEP 8 for Python code
- Testing
  - Write unit tests for new functions
  - Update existing tests if behavior changes
  - Ensure test coverage remains adequate
  - Run tests locally before submitting

## Submmiting a Pull Request

Ensure you're using the [devcontainer](.devcontainer/devcontainer.json)
or install the pre-commit hooks before making any commits.

1. Create a feature branch: `git checkout -b feature/your-feature-name`
1. Make your changes
1. Write or update tests and documentation
1. Run the test suite and pre-commit checks: `pytest && pre-commit run --all-files`
1. Commit with clear messages following Conventional Commits
1. Push to your fork
1. Create a PR with a clear title and description and ensure CI is passing

## Code of Conduct

Be respectful and constructive in all interactions. We're committed to
providing a welcoming environment for all contributors.

## Questions?

Feel free to open an issue or start a discussion if you have a question or a
feature request.
However please keep in mind support for this project is provided on a
**best effort** basis. The authors do not guarantee or warrant that
its efforts will solve the issue or provide a specific result.
