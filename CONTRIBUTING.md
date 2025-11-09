# Contributing to AWS EKS Cluster CLI

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Issues

Before creating an issue, please:
1. Check existing issues to avoid duplicates
2. Use the issue template if available
3. Provide detailed information about the problem
4. Include steps to reproduce the issue
5. Specify your environment (OS, AWS CLI version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
1. Check if the enhancement has already been suggested
2. Provide a clear description of the enhancement
3. Explain why this enhancement would be useful
4. Consider the scope and complexity

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the coding standards
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description

#### Pull Request Process

1. Ensure your code follows the project's coding standards
2. Update the README.md if you change functionality
3. Add tests for new features
4. Ensure all tests pass
5. Update the CHANGELOG.md
6. Request review from maintainers

## Development Setup

### Prerequisites

- AWS CLI v2.0+
- kubectl v1.28+
- Helm v3.12+
- jq v1.6+
- shellcheck (for linting)
- yamllint (for YAML validation)

### Local Development

```bash
# Clone the repository
git clone https://github.com/uldyssian-sh/aws-eks-cluster-awscli.git
cd aws-eks-cluster-awscli

# Set up development environment
make dev-setup

# Run linting
make lint

# Test your changes
make test
```

## Coding Standards

### Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -euo pipefail`
- Use meaningful variable names
- Add comments for complex logic
- Follow shellcheck recommendations
- Use consistent indentation (2 spaces)

### YAML Files

- Use 2 spaces for indentation
- Follow yamllint rules
- Use meaningful names for resources
- Add appropriate labels and annotations

### Documentation

- Use clear, concise language
- Provide examples where helpful
- Keep documentation up to date
- Follow Markdown best practices

## Testing

### Manual Testing

Before submitting changes:
1. Test script functionality
2. Verify documentation accuracy
3. Check for breaking changes
4. Test cleanup procedures

### Automated Testing

Run the test suite:
```bash
# Run all tests
make test

# Run specific tests
./tests/test-cluster.sh cluster
./tests/test-cluster.sh nodes
```

## Security

### Security Considerations

- Never commit sensitive information
- Use placeholder values in examples
- Follow AWS security best practices
- Implement least privilege principles

### Reporting Security Issues

Please report security vulnerabilities privately to the maintainers.

## Release Process

1. Update version numbers
2. Update CHANGELOG.md
3. Create release notes
4. Tag the release
5. Update documentation

## Style Guide

### Commit Messages

Use conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

## Getting Help

### Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)

### Contact

- Create an issue for questions
- Join discussions in pull requests
- Check existing documentation

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- CHANGELOG.md

Thank you for contributing to make this project better!# Updated Sun Nov  9 12:50:10 CET 2025
# Updated Sun Nov  9 12:52:14 CET 2025
# Updated Sun Nov  9 12:56:45 CET 2025
