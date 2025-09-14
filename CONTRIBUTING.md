# Contributing to AWS EKS Cluster AWSCLI

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🤝 How to Contribute

### Reporting Issues
- Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml) for bugs
- Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.yml) for enhancements
- Search existing issues before creating new ones

### Development Process

#### 1. Fork and Clone
```bash
git clone https://github.com/YOUR_USERNAME/aws-eks-cluster-awscli.git
cd aws-eks-cluster-awscli
```

#### 2. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

#### 3. Make Changes
- Follow existing code style and conventions
- Add tests for new functionality
- Update documentation as needed

#### 4. Test Your Changes
```bash
# Validate shell scripts
shellcheck scripts/*.sh

# Test configurations
bash scripts/validate-config.sh --dry-run
```

#### 5. Commit and Push
```bash
git add .
git commit -m "feat: add your feature description"
git push origin feature/your-feature-name
```

#### 6. Create Pull Request
- Use descriptive title and description
- Reference related issues
- Ensure CI/CD pipeline passes

## 📋 Code Standards

### Shell Scripts
- Use `#!/bin/bash` shebang
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Include error handling with `set -euo pipefail`
- Add comments for complex logic

### YAML Files
- Use 2-space indentation
- Validate with yamllint
- Follow Kubernetes conventions

### Documentation
- Update README.md for new features
- Add inline comments for complex configurations
- Include examples and use cases

## 🏷️ Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `chore:` - Maintenance tasks

## 🔍 Code Review Process

1. **Automated Checks**: CI/CD pipeline must pass
2. **Peer Review**: At least one maintainer approval required
3. **Testing**: Manual testing in development environment
4. **Documentation**: Ensure documentation is updated

## 🚀 Release Process

- Releases follow [Semantic Versioning](https://semver.org/)
- Automated releases via GitHub Actions
- Release notes generated automatically
- Tagged releases for stable versions

## 💡 Feature Development Guidelines

### Cost Optimization Features
- Benchmark performance impact
- Provide cost analysis and projections
- Include monitoring and alerting

### Security Features
- Follow security best practices
- Include vulnerability scanning
- Provide compliance documentation

### Multi-region Features
- Test across multiple AWS regions
- Consider latency and availability
- Document regional limitations

## 🤔 Questions and Support

- **General Questions**: Use [GitHub Discussions](../../discussions)
- **Bug Reports**: Use [Issues](../../issues)
- **Feature Requests**: Use [Issues](../../issues) with feature template
- **Security Issues**: Email maintainers directly

## 📜 Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

## 🏆 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- GitHub contributor statistics

## 📚 Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Shell Scripting Best Practices](https://google.github.io/styleguide/shellguide.html)

---

**Thank you for contributing to the AWS EKS automation ecosystem!** 🌟