# Security Policy

## 🔒 Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | ✅ Fully supported |
| 0.x.x   | ❌ No longer supported |

## 🚨 Reporting Security Vulnerabilities

We take security seriously. If you discover a security vulnerability, please follow these steps:

### 1. **Do NOT** create a public issue
Security vulnerabilities should not be reported through public GitHub issues.

### 2. Report Privately
Send details to: **security@uldyssian-sh.dev** (or create a private security advisory)

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

### 3. Response Timeline
- **24 hours**: Acknowledgment of report
- **72 hours**: Initial assessment
- **7 days**: Detailed response with timeline
- **30 days**: Resolution target

## 🛡️ Security Best Practices

### AWS Credentials
- Never commit AWS credentials to repository
- Use IAM roles and policies with least privilege
- Rotate credentials regularly
- Use AWS Secrets Manager for sensitive data

### EKS Security
- Enable audit logging
- Use Pod Security Standards
- Implement network policies
- Regular security scanning with tools like Trivy

### Script Security
- Input validation and sanitization
- Secure temporary file handling
- Proper error handling
- Regular dependency updates

## 🔍 Security Scanning

This repository uses:
- **GitHub Security Advisories** for vulnerability tracking
- **Dependabot** for dependency updates
- **CodeQL** for code analysis
- **Super Linter** for security checks

## 📋 Security Checklist

Before deploying:
- [ ] Review IAM permissions
- [ ] Enable EKS audit logging
- [ ] Configure network security groups
- [ ] Implement Pod Security Standards
- [ ] Set up monitoring and alerting
- [ ] Regular backup and disaster recovery testing

## 🏆 Security Hall of Fame

We recognize security researchers who help improve our security:

*No reports yet - be the first!*

---

**Security is a shared responsibility. Thank you for helping keep our community safe!** 🛡️