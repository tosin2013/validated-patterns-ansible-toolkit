# Support

Thank you for using the Validated Patterns Ansible Toolkit! This document provides information on how to get help and support.

## 📚 Documentation

Before seeking support, please check our comprehensive documentation:

### Getting Started
- [README.md](README.md) - Project overview and quick start
- [Getting Started Guide](docs/tutorials/getting-started.md) - Step-by-step tutorial
- [Quick Start](docs/QUICK-START.md) - Fast deployment guide

### User Guides
- [End-User Guide](docs/END-USER-GUIDE.md) - For deploying patterns
- [Developer Guide](docs/DEVELOPER-GUIDE.md) - For contributors and developers
- [Ansible Roles Reference](docs/ANSIBLE-ROLES-REFERENCE.md) - Detailed role documentation

### Architecture & Design
- [Architecture Documentation](docs/ARCHITECTURE.md) - System architecture
- [Architecture Diagrams](docs/ARCHITECTURE-DIAGRAMS.md) - Visual diagrams
- [ADR Directory](docs/adr/) - Architecture Decision Records (14 ADRs)

### Troubleshooting
- [Troubleshooting Guide](docs/TROUBLESHOOTING-COMPREHENSIVE.md) - Common issues and solutions
- [Deployment Decision Flowchart](docs/DEPLOYMENT-DECISION-FLOWCHART.md) - Deployment path selection

## 💬 Community Support

### GitHub Discussions (Recommended)

For questions, ideas, and community discussions:

**[GitHub Discussions](https://github.com/tosin2013/validated-patterns-ansible-toolkit/discussions)**

Use discussions for:
- ❓ **Q&A**: Ask questions about usage, configuration, or deployment
- 💡 **Ideas**: Share ideas for new features or improvements
- 🎉 **Show and Tell**: Share your patterns and deployments
- 📢 **Announcements**: Stay updated on releases and changes

### GitHub Issues

For bug reports and feature requests:

**[GitHub Issues](https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues)**

Use issues for:
- 🐛 **Bug Reports**: Report bugs or unexpected behavior
- ✨ **Feature Requests**: Request new features or enhancements
- 📝 **Documentation**: Report documentation issues or gaps

**Before creating an issue:**
1. Search existing issues to avoid duplicates
2. Check the troubleshooting guide
3. Gather relevant information (logs, versions, configurations)

## 🔍 Self-Service Resources

### Examples

- **Quarkus Reference App**: [quarkus-reference-app/](quarkus-reference-app/)
- **Integration Tests**: [tests/integration/](tests/integration/)
- **Week-by-Week Examples**: [tests/week8/](tests/week8/), [tests/week9/](tests/week9/), [tests/week10/](tests/week10/)

### Common Questions

#### Q: How do I deploy a pattern?

**A:** See the [End-User Guide](docs/END-USER-GUIDE.md) for step-by-step instructions.

Quick summary:
```bash
# 1. Clone repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# 2. Configure values
cp values-global.yaml.example values-global.yaml
# Edit values-global.yaml with your settings

# 3. Deploy
ansible-playbook files/playbook.yml
```

#### Q: How do I extract and reuse individual Ansible roles?

**A:** See the [Ansible Roles Reference](docs/ANSIBLE-ROLES-REFERENCE.md).

Quick summary:
```bash
# Copy role to your project
cp -r ansible/roles/validated_patterns_deploy /path/to/your/project/roles/

# Use in your playbook
- hosts: localhost
  roles:
    - validated_patterns_deploy
```

#### Q: How do I contribute?

**A:** See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

#### Q: How do I report a security vulnerability?

**A:** See [SECURITY.md](SECURITY.md) for security reporting procedures.

**DO NOT** create a public issue for security vulnerabilities.

#### Q: What OpenShift versions are supported?

**A:** OpenShift 4.12+ is supported. See [ADR-009](docs/adr/ADR-009-openshift-ai-validation.md) for details.

#### Q: Can I use this with other applications besides Quarkus?

**A:** Yes! The Quarkus app is just one example. You can deploy:
- OpenShift AI notebooks
- Any containerized application
- Custom workloads
- Multiple applications

See [ADR-004](docs/adr/ADR-004-quarkus-reference-application.md) for details.

#### Q: How do I customize Helm values?

**A:** Edit `values-global.yaml` and `values-hub.yaml`. See [Configuration Guide](docs/CONFIGURATION.md).

#### Q: Pre-commit hooks are failing, what do I do?

**A:** See [CONTRIBUTING-PRE-COMMIT.md](docs/CONTRIBUTING-PRE-COMMIT.md) for troubleshooting.

Common fixes:
```bash
# Update pre-commit
pre-commit autoupdate

# Run manually to see errors
pre-commit run --all-files

# Skip hooks temporarily (not recommended)
git commit --no-verify
```

## 🐛 Reporting Bugs

When reporting bugs, please include:

### System Information
- OpenShift version
- Ansible version
- Operating system
- Container engine (podman/docker)

### Bug Details
- Clear description of the issue
- Expected behavior
- Actual behavior
- Steps to reproduce
- Error messages or logs
- Screenshots (if applicable)

### Example Bug Report

```markdown
**Description**
The validated_patterns_deploy role fails when deploying to OpenShift 4.14

**Expected Behavior**
Pattern should deploy successfully

**Actual Behavior**
Deployment fails with error: "ArgoCD application not found"

**Steps to Reproduce**
1. Clone repository
2. Configure values-global.yaml
3. Run: ansible-playbook files/playbook.yml
4. Observe error in validated_patterns_deploy role

**Environment**
- OpenShift: 4.14.3
- Ansible: 2.15.5
- OS: RHEL 9.2
- Container Engine: podman 4.6.1

**Logs**
```
TASK [validated_patterns_deploy : Deploy pattern] ***
fatal: [localhost]: FAILED! => {
    "msg": "ArgoCD application 'my-pattern' not found"
}
```

**Additional Context**
This works fine on OpenShift 4.13
```

## 📧 Direct Contact

For specific inquiries that don't fit the above channels:

- **Email**: [tosin.akinosho@gmail.com](mailto:tosin.akinosho@gmail.com)
- **Subject**: `[Validated Patterns Toolkit] <brief description>`

**Note**: For faster responses, please use GitHub Discussions or Issues when possible.

## 🕐 Response Times

We aim for the following response times:

| Channel | Response Time |
|---------|---------------|
| **Security Issues** | 24 hours |
| **Critical Bugs** | 48 hours |
| **GitHub Discussions** | 2-5 business days |
| **GitHub Issues** | 3-7 business days |
| **Email** | 5-10 business days |

**Note**: This is a community-driven project. Response times may vary based on maintainer availability.

## 🤝 Contributing

The best way to get support is to help improve the project!

- Fix bugs you encounter
- Improve documentation
- Add examples
- Answer questions in discussions
- Review pull requests

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📜 License

This project is licensed under the GNU General Public License v3.0.

This means you can:
- ✅ Use the code freely
- ✅ Modify the code
- ✅ Distribute the code
- ✅ Use commercially

See [LICENSE](LICENSE) for full details.

## 🔗 Related Projects

- [Validated Patterns](https://validatedpatterns.io/) - Official Validated Patterns documentation
- [Red Hat OpenShift GitOps](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html)
- [Ansible Automation Platform](https://www.ansible.com/products/automation-platform)

## 🙏 Acknowledgments

Thank you to all contributors and users of the Validated Patterns Ansible Toolkit!

---

**Need help? Start with [GitHub Discussions](https://github.com/tosin2013/validated-patterns-ansible-toolkit/discussions)!** 💬

