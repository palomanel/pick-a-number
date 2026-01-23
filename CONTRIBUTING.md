# How to contribute

Thank you for your interest in contributing! This document provides guidelines
and instructions for contributing to this project.

## Getting Started

Follow these steps:

1. Fork the repository and/or create a local clone
2. Open the project in VS Code and select `Reopen in Container`
3. Follow the development workflow to create and submit a PR

## Project Structure

```text
.
├── .github/                # GitHub specific settings
│   └── workflows/          # CI/CD jobs
├── .devcontainer/          # Devcontainer configuration
├── docs/                   # Documentation
├── cloudformation/         # Infrastructure as Code
├── src/                    # Application source code
│   └── cloudformation/     # Infrastructure as Code
│   └── frontend/           # Application Frontend
│   └── backend/            # Application Backend
├── tests/                  # Test suite
├── README.md               # Repository information
├── LICENSE                 # MIT License
└── CONTRIBUTING.md         # Contribution guidelines
```

## Conventional Commits Standard

This project adheres to the
[Conventional Commits](https://www.conventionalcommits.org)
standard for commit messages. This provides a clear structure to commit
history and enables automated changelog generation.

## Code Standards

- Repository standards
  - Use [Conventional Commits](https://www.conventionalcommits.org),
    this provides a clear structure to commit
    history and enables automated changelog generation.
  - Use [Semantic Versionionig](https://semver.org/) for release tags,
    under this scheme, version numbers and the way they change convey
    meaning about the underlying code and what has been modified from
    one version to the next.
- Python
  - Follow PEP 8 for Python code
  - Use meaningful variable and function names
  - Add docstrings to functions and classes
  - Keep functions focused and modular
  - Write comments for complex logic

## Testing

All code contributions should include tests:

- Write unit tests for new functions
- Update existing tests if behavior changes
- Ensure test coverage remains adequate
- Run tests locally before submitting

## Submmiting a Pull Request

Ensure you're using the [devcontainer](.devcontainer/devcontainer.json)
or install the pre-commit hooks before making any commits.

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Write or update tests and documentation
4. Run the test suite and pre-commit checks: `pytest && pre-commit run --all-files`
5. Commit with clear messages following [Conventional Commits](#conventional-commits-standard)
6. Push to your fork
7. Create a PR with a clear title and description and ensure CI is passing

## Code of Conduct

Be respectful and constructive in all interactions. We're committed to
providing a welcoming environment for all contributors.

## Questions?

Feel free to open an issue or discussion if you have questions about
contributing.
