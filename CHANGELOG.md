# Changelog

All notable changes to the Validated Patterns Ansible Toolkit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-28

### 🎉 Initial Release

This is the initial release of the **Validated Patterns Ansible Toolkit**, a reference implementation and reusable toolkit for deploying Validated Patterns on OpenShift.

### ✨ Added

#### Core Infrastructure
- **7 Production-Ready Ansible Roles** (3,460+ LOC)
  - `validated_patterns_prerequisites` - Cluster validation (OpenShift version, operators, resources)
  - `validated_patterns_common` - Helm and GitOps infrastructure (ArgoCD, clustergroup chart)
  - `validated_patterns_operator` - VP Operator wrapper (simplified end-user deployment)
  - `validated_patterns_deploy` - Application deployment (ArgoCD applications, BuildConfigs)
  - `validated_patterns_gitea` - Git repository management (local development environment)
  - `validated_patterns_secrets` - Secrets management (sealed secrets, RBAC)
  - `validated_patterns_validate` - Comprehensive validation (pre/post deployment, health checks)

#### Reference Applications
- **Quarkus REST API Reference Application**
  - 30 files, 1,200+ lines of code
  - Helm charts with ArgoCD sync waves
  - Tekton CI/CD pipelines (build, test, deploy)
  - Dev and Prod overlays with Kustomize
  - Complete documentation and examples

#### Documentation (Diataxis Framework)
- **User Guides**
  - End-User Guide (simplified VP Operator workflow)
  - Developer Guide (granular control with individual roles)
  - Quick Start Guide
  - Troubleshooting Guide (comprehensive)
  
- **Architecture Documentation**
  - 14 Architecture Decision Records (ADRs)
  - Architecture diagrams (Mermaid)
  - Deployment decision flowchart
  - Ansible roles reference
  
- **Tutorials & How-Tos**
  - Getting started tutorial
  - Role-by-role deployment guides
  - Quarkus app deployment
  - OpenShift AI validation
  
- **Reference Documentation**
  - Ansible roles API reference
  - Configuration reference
  - Troubleshooting reference

#### Community Health Files
- **CONTRIBUTING.md** - Comprehensive contribution guidelines
- **CODE_OF_CONDUCT.md** - Contributor Covenant v2.1
- **SECURITY.md** - Security policy and vulnerability reporting
- **SUPPORT.md** - Support resources and FAQ
- **GitHub Issue Templates** - Bug report, feature request, documentation
- **GitHub PR Template** - Comprehensive pull request checklist

#### Security Features
- **Pre-commit Hooks** with Gitleaks integration
  - 8 custom rules for Validated Patterns secrets
  - YAML linting with yamllint
  - Trailing whitespace removal
  - End-of-file fixer
  - Large file detection
  - Merge conflict detection
  
- **Gitleaks Configuration** (`.gitleaks.toml`)
  - Custom rules for VP tokens, Ansible Hub, OpenShift, Quay, RHSM, Gitea
  - Comprehensive allowlist for templates, tests, docs
  - ADR-014 documentation

#### Build & Test Infrastructure
- **Makefile** with 10+ targets
  - `make build` - Build execution environment
  - `make test` - Run integration tests
  - `make lint` - YAML linting
  - `make clean` - Clean build artifacts
  - `make publish` - Publish to registry
  
- **Execution Environment**
  - Container-based Ansible runtime
  - Pre-configured with all dependencies
  - Ansible Navigator integration
  
- **Integration Tests**
  - Week 8-10 test suites
  - Role-specific tests
  - Validation tests

#### CI/CD
- **GitHub Actions Workflows**
  - YAML linting on push/PR
  - Pre-commit checks
  - Automated testing
  
- **Tekton Pipelines** (Quarkus app)
  - Build pipeline
  - Test pipeline
  - Deploy pipeline

### 🔒 Security

#### Resolved Security Issues
- **SECURITY-ADVISORY-001**: Exposed Gitea Token (CRITICAL)
  - **Issue**: Gitea token exposed in git history
  - **Resolution**: Git history squashed, token removed from all commits
  - **Date**: 2025-10-28
  - **Status**: RESOLVED ✅

#### Security Improvements
- Pre-commit hooks prevent secret commits
- Gitleaks scans every commit
- Comprehensive security documentation
- Private vulnerability disclosure process

### 📦 Repository Migration

#### From: ansible-execution-environment
- Original repository by John Wadleigh
- Execution environment for Ansible roles

#### To: validated-patterns-ansible-toolkit
- New repository: `tosin2013/validated-patterns-ansible-toolkit`
- Expanded scope: Reference implementation + reusable toolkit
- Enhanced documentation and community files
- Production-ready for community use

#### Migration Details
- **54 files updated** with new repository URLs
- **149 URL replacements** across configuration files
- **Git history squashed** to remove exposed secrets
- **278 developer notes removed** for clean public release
- **Clean git history** with 7 commits

### 🎯 Dual-Workflow Architecture

#### End-User Workflow (Simplified)
- Uses VP Operator (Role 3) for simplified deployment
- Single playbook: `deploy_with_operator.yml`
- Minimal configuration required
- Ideal for production deployments

#### Developer Workflow (Granular Control)
- Uses Roles 1-2, 4-7 for granular control
- Multiple playbooks for different scenarios
- Full customization capabilities
- Ideal for development and testing

### 📊 Statistics

- **Total Files**: 608 files
- **Lines of Code**: 105,653 lines
- **Ansible Roles**: 7 roles (3,460+ LOC)
- **Documentation**: 50+ documentation files
- **ADRs**: 14 architectural decision records
- **Tests**: 20+ integration tests
- **Community Files**: 8 files (1,393 lines)

### 🔗 Links

- **Repository**: https://github.com/tosin2013/validated-patterns-ansible-toolkit
- **Documentation**: https://github.com/tosin2013/validated-patterns-ansible-toolkit/tree/main/docs
- **Issues**: https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues
- **Discussions**: https://github.com/tosin2013/validated-patterns-ansible-toolkit/discussions

### 📜 License

GNU General Public License v3.0 - Allows copying, modification, and distribution.

### 👥 Contributors

- **Tosin Akinosho** (@tosin2013) - Project maintainer
- **John Wadleigh** - Original execution environment repository

### 🙏 Acknowledgments

- [Validated Patterns Community](https://validatedpatterns.io/)
- [Red Hat Communities of Practice](https://github.com/redhat-cop)
- [Ansible Community](https://www.ansible.com/community)

---

## [Unreleased]

### Planned for v1.1.0
- Additional reference applications (Python Flask, Node.js)
- Enhanced OpenShift AI integration
- Additional Tekton pipeline examples
- Performance optimizations
- Extended test coverage

---

## Version History

- **[1.0.0]** - 2025-10-28 - Initial release

---

**Note**: This changelog follows [Keep a Changelog](https://keepachangelog.com/) format and [Semantic Versioning](https://semver.org/).

