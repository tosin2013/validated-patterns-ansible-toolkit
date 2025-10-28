# Validated Patterns Toolkit - Documentation Index

**Version:** 1.0
**Last Updated:** 2025-10-27

---

## Quick Navigation

### 🚀 Getting Started

**New to Validated Patterns?** Start here:

1. **[Which Guide Should I Use?](#which-guide-should-i-use)** - Choose your workflow
2. **[End-User Guide](END-USER-GUIDE.md)** - Deploy existing patterns (recommended for most users)
3. **[Developer Guide](DEVELOPER-GUIDE.md)** - Develop new patterns or customize deployments

### 📚 Complete Documentation

- **[End-User Guide](END-USER-GUIDE.md)** - Simplified deployment with VP Operator
- **[Developer Guide](DEVELOPER-GUIDE.md)** - Full control with development roles
- **[Implementation Plan](IMPLEMENTATION-PLAN.md)** - Project roadmap and progress
- **[Quick Start](QUICK-START-ROLES.md)** - Quick reference for roles

---

## Which Guide Should I Use?

### Use the End-User Guide if you want to:

✅ Deploy an existing validated pattern
✅ Get started quickly (5 minutes)
✅ Use operator-managed deployment
✅ Minimal configuration required
✅ Production deployment without customization

**→ [Go to End-User Guide](END-USER-GUIDE.md)**

### Use the Developer Guide if you want to:

✅ Develop a new validated pattern
✅ Customize pattern deployment
✅ Debug pattern issues
✅ Test pattern changes locally
✅ Integrate with CI/CD pipelines
✅ Learn pattern internals

**→ [Go to Developer Guide](DEVELOPER-GUIDE.md)**

---

## Documentation Structure

### User Guides

#### [End-User Guide](END-USER-GUIDE.md)
**Audience:** Pattern consumers
**Workflow:** VP Operator (1 role)
**Time to Deploy:** 5-15 minutes

**Contents:**
- Quick Start (5 minutes)
- Prerequisites
- Configuration (values files)
- Deployment methods
- Monitoring
- Troubleshooting
- Examples

**Best For:**
- Deploying existing patterns
- Production deployments
- Quick evaluation
- Managed lifecycle

#### [Developer Guide](DEVELOPER-GUIDE.md)
**Audience:** Pattern developers
**Workflow:** Development Roles (6 roles)
**Time to Deploy:** 30-60 minutes

**Contents:**
- Development workflow
- Role-by-role guide
- Complete examples
- Testing and validation
- Troubleshooting
- Best practices

**Best For:**
- Pattern development
- Custom deployments
- Debugging
- CI/CD integration
- Learning internals

---

## Workflow Comparison

### End-User Workflow (VP Operator)

```
┌─────────────────────────────────────────┐
│         End-User Workflow               │
│         (1 Role - Simple)               │
└─────────────────────────────────────────┘

Step 1: Edit values-*.yaml files
  ↓
Step 2: Run ansible-playbook
  ↓
VP Operator Handles Everything:
  ├─ Installs OpenShift GitOps
  ├─ Creates Pattern CR
  ├─ Deploys Applications
  └─ Validates Deployment
```

**Pros:**
- ✅ Simple (1 role)
- ✅ Quick (5 minutes)
- ✅ Operator-managed
- ✅ Production-ready

**Cons:**
- ⚠️ Less control
- ⚠️ Limited customization

**Use Cases:**
- Production deployment
- Pattern consumption
- Quick evaluation

### Developer Workflow (6 Roles)

```
┌─────────────────────────────────────────┐
│       Developer Workflow                │
│       (6 Roles - Full Control)          │
└─────────────────────────────────────────┘

Role 1: validated_patterns_prerequisites
  ↓ Validates cluster readiness

Role 2: validated_patterns_common
  ↓ Deploys common infrastructure

Role 4: validated_patterns_deploy
  ↓ Deploys pattern applications

Role 5: validated_patterns_gitea
  ↓ Sets up local development

Role 6: validated_patterns_secrets
  ↓ Manages secrets

Role 7: validated_patterns_validate
  ↓ Validates deployment
```

**Pros:**
- ✅ Full control
- ✅ Granular execution
- ✅ Customizable
- ✅ Debuggable

**Cons:**
- ⚠️ More complex
- ⚠️ Requires knowledge
- ⚠️ More configuration

**Use Cases:**
- Pattern development
- Custom deployments
- Debugging
- CI/CD integration

---

## Quick Reference

### Common Tasks

#### Deploy Existing Pattern (End-User)

```bash
# 1. Login to OpenShift
oc login <cluster-url>

# 2. Clone pattern
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# 3. Edit configuration
vi quarkus-reference-app/values-global.yaml
vi quarkus-reference-app/values-hub.yaml

# 4. Deploy
ansible-playbook ansible/playbooks/deploy_with_operator.yml \
  -e validated_patterns_pattern_name=quarkus-reference-app \
  -e validated_patterns_git_url=https://github.com/tosin2013/validated-patterns-ansible-toolkit.git

# 5. Monitor
oc get applications -n openshift-gitops -w
```

**→ [Full End-User Guide](END-USER-GUIDE.md)**

#### Develop New Pattern (Developer)

```bash
# 1. Login to OpenShift
oc login <cluster-url>

# 2. Clone repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# 3. Run prerequisites check
ansible-navigator run ansible/playbooks/test_prerequisites.yml

# 4. Deploy common infrastructure
ansible-navigator run ansible/playbooks/install_gitops.yml

# 5. Deploy pattern
ansible-navigator run ansible/playbooks/deploy_complete_pattern.yml \
  -e validated_patterns_pattern_name=my-pattern \
  -e validated_patterns_repo_url=https://github.com/myorg/my-pattern.git

# 6. Validate
ansible-playbook ansible/roles/validated_patterns_validate/tests/test.yml
```

**→ [Full Developer Guide](DEVELOPER-GUIDE.md)**

---

## Additional Documentation

### Architecture & Design

- **[ADR Index](adr/README.md)** - Architecture Decision Records
- **[ADR-002: Ansible Role Architecture](adr/ADR-002-ansible-role-architecture.md)**
- **[ADR-013: Deployment Strategy](adr/ADR-013-validated-patterns-deployment-strategy.md)**

### Reference Documentation

- **[Execution Environment YAML](reference/execution-environment-yaml.md)**
- **[Make Targets](reference/make-targets.md)**
- **[Tooling Reference](reference/tooling.md)**

### How-To Guides

- **[Build Locally](how-to/build-locally.md)**
- **[Testing Execution Environment](how-to/testing-execution-environment.md)**
- **[Troubleshoot EE Builds](how-to/troubleshoot-ee-builds.md)**
- **[CI/CD Integration](how-to/ci-cd.md)**

### Tutorials

- **[Getting Started](tutorials/getting-started.md)**
- **[Quick Start with Ansible Navigator](tutorials/quick-start-ansible-navigator.md)**

### Explanation

- **[Concepts](explanation/concepts.md)**
- **[Design Decisions](explanation/design-decisions.md)**
- **[Technology Stack](explanation/technology-stack.md)**

---

## Project Status

### Phase Completion

- ✅ **Phase 1:** Foundation (Weeks 1-2) - COMPLETE
- ✅ **Phase 2:** Core Ansible Roles (Weeks 3-5) - COMPLETE
- ✅ **Phase 2.5:** Quarkus Reference App (Weeks 6-7) - COMPLETE
- ✅ **Phase 3:** Validation & Testing (Weeks 8-10) - COMPLETE
- 🔄 **Phase 4:** Documentation & Release (Weeks 11-16) - IN PROGRESS

### Current Progress

- **Overall:** 65% complete (10.5 of 16 weeks)
- **Current Week:** Week 11 - Documentation & Polish
- **Status:** Developer and End-User guides complete

**→ [View Implementation Plan](IMPLEMENTATION-PLAN.md)**

---

## Getting Help

### Documentation Issues

If you find issues with the documentation:

1. **Check Troubleshooting Sections:**
   - [End-User Guide Troubleshooting](END-USER-GUIDE.md#troubleshooting)
   - [Developer Guide Troubleshooting](DEVELOPER-GUIDE.md#troubleshooting)

2. **Search Existing Issues:**
   - [GitHub Issues](https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues)

3. **Create New Issue:**
   - [Report Documentation Issue](https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues/new)

### Community Support

- **Validated Patterns:** https://validatedpatterns.io
- **OpenShift GitOps:** https://docs.openshift.com/gitops/
- **Red Hat Hybrid Cloud Patterns:** https://hybrid-cloud-patterns.io

---

## Contributing

We welcome contributions to improve the documentation!

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Submit a pull request**

### Documentation Standards

- Use clear, concise language
- Include code examples
- Provide expected outputs
- Add troubleshooting tips
- Test all commands
- Update version and date

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-27 | Initial release with Developer and End-User guides |

---

## License

Apache 2.0

---

## Maintainers

**Validated Patterns Toolkit Development Team**

For questions or feedback, please open an issue on GitHub.

---

**Last Updated:** 2025-10-27
**Document Version:** 1.0
