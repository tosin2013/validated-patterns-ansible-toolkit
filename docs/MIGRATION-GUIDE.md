# Migration Guide

This guide helps users migrate from the original `ansible-execution-environment` repository to the new `validated-patterns-ansible-toolkit` repository.

## 📋 Overview

### What Changed?

| Aspect | Before (ansible-execution-environment) | After (validated-patterns-ansible-toolkit) |
|--------|----------------------------------------|-------------------------------------------|
| **Repository Name** | `ansible-execution-environment` | `validated-patterns-ansible-toolkit` |
| **Repository URL** | `https://github.com/tosin2013/ansible-execution-environment` | `https://github.com/tosin2013/validated-patterns-ansible-toolkit` |
| **Purpose** | Execution environment for Ansible | Reference implementation + reusable toolkit |
| **Scope** | Container infrastructure | 7 Ansible roles + reference apps + docs |
| **Documentation** | Basic README | Comprehensive Diataxis framework |
| **Community Files** | None | CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, SUPPORT |
| **Security** | No pre-commit hooks | Pre-commit hooks + gitleaks (8 rules) |

### Why the Change?

The repository has evolved from a simple execution environment to a **comprehensive toolkit** for deploying Validated Patterns. The new name better reflects its purpose as a:

- ✅ **Reference Implementation** - Example of best practices
- ✅ **Reusable Toolkit** - 7 production-ready Ansible roles
- ✅ **Template Repository** - Clone/fork/copy for your own patterns
- ✅ **Learning Resource** - Comprehensive documentation and examples

## 🚀 Migration Steps

### Step 1: Update Git Remote

If you have an existing clone of the old repository:

```bash
# Navigate to your local repository
cd ansible-execution-environment

# Update the remote URL
git remote set-url origin https://github.com/tosin2013/validated-patterns-ansible-toolkit.git

# Verify the change
git remote -v

# Pull the latest changes
git pull origin main
```

### Step 2: Update Configuration Files

If you have custom configuration files that reference the old repository:

```bash
# Find all files with old repository references
grep -r "ansible-execution-environment" . --exclude-dir=.git

# Update each file manually or use sed (review changes carefully!)
find . -type f -not -path "./.git/*" -exec sed -i 's|ansible-execution-environment|validated-patterns-ansible-toolkit|g' {} +
```

**Files that may need updates:**
- `values-global.yaml`
- `values-hub.yaml`
- Custom playbooks
- CI/CD configurations
- Documentation

### Step 3: Update Ansible Galaxy Requirements

If you're using `requirements.yml` to install roles:

**Before:**
```yaml
# requirements.yml
roles:
  - src: https://github.com/tosin2013/ansible-execution-environment
    name: validated_patterns
```

**After:**
```yaml
# requirements.yml
roles:
  - src: https://github.com/tosin2013/validated-patterns-ansible-toolkit
    name: validated_patterns
```

Or install individual roles:

```yaml
# requirements.yml
roles:
  - src: https://github.com/tosin2013/validated-patterns-ansible-toolkit
    name: validated_patterns_prerequisites
  - src: https://github.com/tosin2013/validated-patterns-ansible-toolkit
    name: validated_patterns_common
  # ... other roles
```

### Step 4: Update CI/CD Pipelines

If you have CI/CD pipelines that reference the old repository:

**GitHub Actions:**
```yaml
# Before
- uses: actions/checkout@v3
  with:
    repository: tosin2013/ansible-execution-environment

# After
- uses: actions/checkout@v3
  with:
    repository: tosin2013/validated-patterns-ansible-toolkit
```

**GitLab CI:**
```yaml
# Before
variables:
  REPO_URL: https://github.com/tosin2013/ansible-execution-environment

# After
variables:
  REPO_URL: https://github.com/tosin2013/validated-patterns-ansible-toolkit
```

**Tekton:**
```yaml
# Before
- name: git-url
  value: https://github.com/tosin2013/ansible-execution-environment

# After
- name: git-url
  value: https://github.com/tosin2013/validated-patterns-ansible-toolkit
```

### Step 5: Install Pre-commit Hooks (Recommended)

The new repository includes pre-commit hooks for security and quality:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Test hooks
pre-commit run --all-files
```

See [CONTRIBUTING-PRE-COMMIT.md](CONTRIBUTING-PRE-COMMIT.md) for details.

## 🔄 What Stayed the Same?

### Ansible Roles

All 7 Ansible roles remain **functionally identical**:

- `validated_patterns_prerequisites`
- `validated_patterns_common`
- `validated_patterns_operator`
- `validated_patterns_deploy`
- `validated_patterns_gitea`
- `validated_patterns_secrets`
- `validated_patterns_validate`

**Your existing playbooks should work without changes** (except for repository URL updates).

### Execution Environment

The execution environment build process remains the same:

```bash
# Still works the same way
export ANSIBLE_HUB_TOKEN="your-token"
make build
make test
```

### Deployment Workflows

Both deployment workflows are preserved:

- **End-User Workflow**: `deploy_with_operator.yml` (unchanged)
- **Developer Workflow**: `deploy_complete_pattern.yml` (unchanged)

## 📚 New Features

### Community Health Files

The new repository includes comprehensive community files:

- **[CONTRIBUTING.md](../CONTRIBUTING.md)** - How to contribute
- **[CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md)** - Community standards
- **[SECURITY.md](../SECURITY.md)** - Security policy
- **[SUPPORT.md](../SUPPORT.md)** - Support resources

### Enhanced Documentation

New documentation structure using Diataxis framework:

- **[Tutorials](tutorials/)** - Learning-oriented guides
- **[How-To Guides](how-to/)** - Task-oriented instructions
- **[Reference](reference/)** - Information-oriented docs
- **[Explanation](explanation/)** - Understanding-oriented content

### Security Improvements

- Pre-commit hooks with gitleaks (8 custom rules)
- Automated secret scanning
- Security advisory process
- Comprehensive security documentation

## 🔍 Breaking Changes

### None!

There are **no breaking changes** to the Ansible roles or deployment workflows. The migration is primarily about:

1. Updating repository URLs
2. Taking advantage of new features (optional)
3. Following new community guidelines (for contributors)

## 🆘 Troubleshooting

### Issue: Git remote update fails

**Error:**
```
fatal: remote origin already exists.
```

**Solution:**
```bash
# Remove old remote
git remote remove origin

# Add new remote
git remote add origin https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
```

### Issue: Pre-commit hooks fail

**Error:**
```
[ERROR] Gitleaks has detected secrets
```

**Solution:**
See [CONTRIBUTING-PRE-COMMIT.md](CONTRIBUTING-PRE-COMMIT.md) for troubleshooting pre-commit issues.

### Issue: Old URLs still referenced

**Problem:** Some files still reference the old repository URL.

**Solution:**
```bash
# Find all references
grep -r "ansible-execution-environment" . --exclude-dir=.git

# Update manually or with sed
sed -i 's|ansible-execution-environment|validated-patterns-ansible-toolkit|g' <file>
```

## 📞 Getting Help

If you encounter issues during migration:

1. **Check Documentation**: [SUPPORT.md](../SUPPORT.md)
2. **Search Issues**: [GitHub Issues](https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues)
3. **Ask Questions**: [GitHub Discussions](https://github.com/tosin2013/validated-patterns-ansible-toolkit/discussions)
4. **Report Bugs**: [Bug Report Template](https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues/new?template=bug_report.yml)

## 📋 Migration Checklist

Use this checklist to track your migration:

- [ ] Update git remote URL
- [ ] Pull latest changes from new repository
- [ ] Update configuration files (values-global.yaml, values-hub.yaml)
- [ ] Update custom playbooks with new repository URLs
- [ ] Update CI/CD pipelines
- [ ] Update Ansible Galaxy requirements.yml
- [ ] Install pre-commit hooks (optional but recommended)
- [ ] Test deployment with updated configuration
- [ ] Update documentation/README in your fork
- [ ] Review new community health files
- [ ] Subscribe to GitHub Discussions for updates

## 🎯 Next Steps

After migration:

1. **Explore New Features**
   - Review the [CHANGELOG.md](../CHANGELOG.md)
   - Check out new documentation structure
   - Try pre-commit hooks

2. **Contribute Back**
   - Read [CONTRIBUTING.md](../CONTRIBUTING.md)
   - Share your patterns and examples
   - Report issues or suggest improvements

3. **Stay Updated**
   - Watch the repository on GitHub
   - Subscribe to GitHub Discussions
   - Follow release notes

## 📜 License

The repository remains under **GNU General Public License v3.0**, which allows you to:

- ✅ Copy and use the code
- ✅ Modify the code
- ✅ Distribute the code
- ✅ Use commercially

See [LICENSE](../LICENSE) for full details.

---

**Questions?** Open a [GitHub Discussion](https://github.com/tosin2013/validated-patterns-ansible-toolkit/discussions) or check [SUPPORT.md](../SUPPORT.md).

