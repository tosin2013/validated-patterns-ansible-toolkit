# Security Policy

## 🔒 Security Overview

The Validated Patterns Ansible Toolkit takes security seriously. This document outlines our security practices, how to report vulnerabilities, and our security tooling.

## 🛡️ Security Features

### Pre-commit Hooks with Gitleaks

We use **pre-commit hooks** with **gitleaks** to prevent secrets from being committed to the repository.

**Configured Checks:**
- Gitleaks secret scanning (8 custom rules)
- YAML syntax validation
- Trailing whitespace removal
- End-of-file fixer
- Large file detection
- Merge conflict detection

**Setup for Contributors:**
```bash
pip install pre-commit
pre-commit install
```

See [CONTRIBUTING-PRE-COMMIT.md](docs/CONTRIBUTING-PRE-COMMIT.md) for detailed setup instructions.

### Gitleaks Configuration

We have configured gitleaks with **8 custom rules** specific to Validated Patterns:

1. **validated-patterns-token** - Validated Patterns API tokens
2. **ansible-vault-password** - Ansible Vault passwords
3. **ansible-hub-token** - Ansible Automation Hub tokens
4. **openshift-token** - OpenShift API tokens (sha256~ format)
5. **quay-token** - Quay.io registry tokens
6. **redhat-registry-password** - Red Hat registry credentials
7. **rhsm-activation-key** - RHSM activation keys
8. **gitea-admin-password** - Gitea admin passwords

**Configuration File:** `.gitleaks.toml`

**Allowlist:**
- Template files (`*.template`, `*-secrets.yaml.template`)
- Test files (`tests/*.example`, `tests/*.sample`)
- Documentation (`docs/**/*.md`, `README.md`, ADRs)
- CI/CD workflows (`.github/workflows/*.yml`)
- Ansible variables and placeholders

See [ADR-014: Pre-commit Hooks and Gitleaks Integration](docs/adr/ADR-014-pre-commit-hooks-gitleaks.md) for architectural decisions.

## 🚨 Reporting a Vulnerability

### Where to Report

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, report security vulnerabilities privately to:
- **Email**: [tosin.akinosho@gmail.com](mailto:tosin.akinosho@gmail.com)
- **Subject**: `[SECURITY] Validated Patterns Ansible Toolkit - <brief description>`

### What to Include

Please include the following information:

1. **Description**: Clear description of the vulnerability
2. **Impact**: Potential impact and severity
3. **Steps to Reproduce**: Detailed steps to reproduce the issue
4. **Affected Versions**: Which versions are affected
5. **Suggested Fix**: If you have a suggested fix (optional)
6. **Your Contact**: How we can reach you for follow-up

### Example Report

```
Subject: [SECURITY] Validated Patterns Ansible Toolkit - Exposed API Token in Role

Description:
The validated_patterns_deploy role exposes an API token in the task output
when running with -vvv verbosity.

Impact:
HIGH - API tokens could be exposed in CI/CD logs or terminal output.

Steps to Reproduce:
1. Run: ansible-playbook -vvv deploy_pattern.yml
2. Observe task output for "Deploy Pattern" task
3. API token visible in output

Affected Versions:
All versions prior to v1.0.0

Suggested Fix:
Add no_log: true to the task in roles/validated_patterns_deploy/tasks/deploy_pattern.yml

Contact:
security-researcher@example.com
```

## 📋 Response Process

### Timeline

- **24 hours**: Initial acknowledgment of report
- **7 days**: Initial assessment and severity classification
- **30 days**: Fix developed and tested (for HIGH/CRITICAL)
- **90 days**: Public disclosure (after fix is released)

### Severity Classification

| Severity | Description | Response Time |
|----------|-------------|---------------|
| **CRITICAL** | Immediate risk of data breach, RCE, or privilege escalation | 24-48 hours |
| **HIGH** | Significant security impact, exposed secrets, authentication bypass | 7 days |
| **MEDIUM** | Moderate security impact, information disclosure | 30 days |
| **LOW** | Minor security impact, best practice violations | 90 days |

### Communication

We will:
1. Acknowledge receipt of your report
2. Provide regular updates on progress
3. Credit you in the security advisory (if desired)
4. Notify you before public disclosure

## 🔐 Security Best Practices

### For Contributors

1. **Never Commit Secrets**
   - Use Ansible Vault for sensitive data
   - Use environment variables for tokens
   - Use sealed secrets for Kubernetes secrets
   - Pre-commit hooks will catch most secrets

2. **Use Secure Defaults**
   - Default to secure configurations
   - Require explicit opt-in for insecure options
   - Document security implications

3. **Validate Input**
   - Validate all user input
   - Sanitize data before use
   - Use Ansible's built-in validation

4. **Follow Least Privilege**
   - Request minimum required permissions
   - Use service accounts, not admin accounts
   - Document required permissions

### For Users

1. **Protect Credentials**
   - Store credentials in Ansible Vault
   - Use environment variables for tokens
   - Never commit credentials to Git
   - Rotate credentials regularly

2. **Review Configurations**
   - Review values files before deployment
   - Understand what each role does
   - Use network policies to restrict access
   - Enable RBAC and pod security

3. **Keep Updated**
   - Update to latest versions
   - Review security advisories
   - Apply security patches promptly

4. **Monitor Deployments**
   - Monitor for suspicious activity
   - Review logs regularly
   - Use OpenShift security features
   - Enable audit logging

## 🔍 Security Scanning

### Automated Scanning

We use the following automated security scanning:

1. **Gitleaks** (Pre-commit)
   - Scans every commit for secrets
   - Runs on developer machines
   - Runs in CI/CD pipelines

2. **YAML Linting** (Pre-commit)
   - Validates YAML syntax
   - Checks for common mistakes
   - Enforces consistent formatting

3. **Dependabot** (GitHub)
   - Scans dependencies for vulnerabilities
   - Creates PRs for updates
   - Monitors Python, Ansible, and container dependencies

### Manual Review

Security-sensitive changes require:
- Code review by maintainers
- Security review for authentication/authorization changes
- Testing in isolated environment
- Documentation of security implications

## 📚 Security Resources

### Documentation

- [ADR-014: Pre-commit Hooks and Gitleaks Integration](docs/adr/ADR-014-pre-commit-hooks-gitleaks.md)
- [CONTRIBUTING-PRE-COMMIT.md](docs/CONTRIBUTING-PRE-COMMIT.md)
- [SECURITY-ADVISORY-001: Exposed Gitea Token](docs/SECURITY-ADVISORY-001-EXPOSED-GITEA-TOKEN.md) (Resolved)

### External Resources

- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [Pre-commit Framework](https://pre-commit.com/)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [OpenShift Security](https://docs.openshift.com/container-platform/latest/security/index.html)

## 🏆 Security Hall of Fame

We recognize security researchers who responsibly disclose vulnerabilities:

<!-- Security researchers will be listed here -->

*No vulnerabilities reported yet.*

## 📜 Security Advisories

### Published Advisories

- [SECURITY-ADVISORY-001: Exposed Gitea Token](docs/SECURITY-ADVISORY-001-EXPOSED-GITEA-TOKEN.md) - **RESOLVED** (2025-10-28)
  - Severity: CRITICAL
  - Impact: Exposed Gitea token in git history
  - Resolution: Git history squashed, token removed
  - Status: Resolved

### Subscribing to Advisories

To receive security advisories:
1. Watch this repository on GitHub
2. Enable "Security alerts" in your notification settings
3. Subscribe to GitHub Security Advisories

## 🔄 Security Updates

### Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

### Update Policy

- **Security patches**: Released as soon as possible
- **Minor updates**: Monthly (if needed)
- **Major updates**: Quarterly

## 📞 Contact

For security-related questions or concerns:
- **Email**: [tosin.akinosho@gmail.com](mailto:tosin.akinosho@gmail.com)
- **GitHub Discussions**: For general security questions (not vulnerabilities)

---

**Thank you for helping keep the Validated Patterns Ansible Toolkit secure!** 🔒

