# Validated Patterns Toolkit

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![OpenShift](https://img.shields.io/badge/OpenShift-4.12+-red.svg)](https://www.openshift.com/)
[![Ansible](https://img.shields.io/badge/Ansible-2.15+-black.svg)](https://www.ansible.com/)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/tosin2013/validated-patterns-ansible-toolkit)

**Reference implementation and reusable toolkit** for deploying [Validated Patterns](https://validatedpatterns.io/) on OpenShift.

## 🎯 What is This?

This repository is a **reference implementation and reusable toolkit** for deploying [Validated Patterns](https://validatedpatterns.io/) on OpenShift. It's designed to be:

- ✅ **Cloned/Forked** - Use as a template for your own pattern deployments
- ✅ **Copied** - Extract individual Ansible roles into your projects
- ✅ **Referenced** - Learn best practices for pattern deployment
- ✅ **Extended** - Customize for your specific needs (GPL v3.0 license allows copying and modification)

### 🎁 This is a Template Repository

**You are encouraged to**:
- 🔄 **Fork** this repository and make it your own
- 📋 **Copy** the entire repository for your organization
- 🧩 **Extract** individual Ansible roles for reuse
- 🛠️ **Modify** everything to fit your needs
- 🚀 **Deploy** in your environment without restrictions

The GPL v3.0 license **explicitly allows** you to copy, modify, and use this code. See the [License](#-license) section for details.

### What's Included

- **7 Production-Ready Ansible Roles** (3,460+ LOC) - Reusable in any project
- **Reference Applications** - Quarkus REST API, OpenShift AI validation, extensible to any workload
- **Dual-Workflow Architecture** - Development (granular control) and End-User (simplified) paths
- **Comprehensive Documentation** - Tutorials, how-tos, references, explanations (Diataxis framework)
- **Tekton CI/CD Pipelines** - Example automation and testing
- **Execution Environment** - Container infrastructure for running Ansible roles

## 🚀 Quick Start

### Option 1: Deploy a Complete Pattern (End-User Workflow)

```bash
# Clone the repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# Configure your pattern
vi values-global.yaml  # Edit global configuration
vi values-hub.yaml     # Edit hub configuration

# Deploy using the simplified workflow (VP Operator)
ansible-playbook ansible/playbooks/deploy_with_operator.yml

# See: docs/END-USER-GUIDE.md for details
```

### Option 2: Copy Individual Roles (Reusability)

```bash
# Copy a specific role into your project
cp -r ansible/roles/validated_patterns_prerequisites ~/my-project/roles/

# Use in your playbook
cat > deploy.yml <<EOF
- name: Deploy my pattern
  hosts: localhost
  roles:
    - validated_patterns_prerequisites
    - validated_patterns_common
    - validated_patterns_deploy
EOF

ansible-playbook deploy.yml
```

> **🚀 Coming Soon**: Ansible Galaxy Collection
> In a future release (v1.1.0+), you'll be able to install via:
> `ansible-galaxy collection install tosin2013.validated_patterns_toolkit`
> See [ADR-015](docs/adr/ADR-015-ansible-collection-distribution.md) for details.

### Option 3: Development Workflow (Granular Control)

```bash
# Clone the repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# Build the Execution Environment
export ANSIBLE_HUB_TOKEN="your-token-here"
make build

# Deploy using development workflow (roles 1-2, 4-7)
ansible-playbook ansible/playbooks/deploy_complete_pattern.yml

# See: docs/DEVELOPER-GUIDE.md for details
```

## 📚 Documentation

### Start Here
- **[Release Plan](docs/RELEASE-PLAN.md)** - v1.0 release plan and goals
- **[Quick Reference](docs/RELEASE-QUICK-REFERENCE.md)** - Quick reference card
- **[Guides Index](docs/GUIDES-INDEX.md)** - All guides and documentation

### User Guides (Choose Your Workflow)
- **[End-User Guide](docs/END-USER-GUIDE.md)** - Simplified deployment via VP Operator (Role 3)
- **[Developer Guide](docs/DEVELOPER-GUIDE.md)** - Granular control with Roles 1-2, 4-7

### Diataxis Documentation
- **[Tutorials](docs/tutorials/)** - Learning-oriented guides
- **[How-To Guides](docs/how-to/)** - Task-oriented instructions
- **[Reference](docs/reference/)** - Information-oriented documentation
- **[Explanation](docs/explanation/)** - Understanding-oriented content

### Architecture & Decisions
- **[Architecture Diagrams](docs/ARCHITECTURE-DIAGRAMS.md)** - Visual architecture
- **[ADRs](docs/adr/)** - 14 Architectural Decision Records
- **[Release Plan](docs/RELEASE-PLAN.md)** - v1.0 release plan and progress

## 🔧 7 Reusable Ansible Roles

Each role can be used **independently** or as part of the complete toolkit:

| Role | Purpose | Reusable | Documentation |
|------|---------|----------|---------------|
| **validated_patterns_prerequisites** | Cluster validation (OpenShift version, operators, resources) | ✅ Yes | [README](ansible/roles/validated_patterns_prerequisites/README.md) |
| **validated_patterns_common** | Helm and GitOps infrastructure (ArgoCD, clustergroup chart) | ✅ Yes | [README](ansible/roles/validated_patterns_common/README.md) |
| **validated_patterns_operator** | VP Operator wrapper (simplified end-user deployment) | ✅ Yes | [README](ansible/roles/validated_patterns_operator/README.md) |
| **validated_patterns_deploy** | Application deployment (ArgoCD applications, BuildConfigs) | ✅ Yes | [README](ansible/roles/validated_patterns_deploy/README.md) |
| **validated_patterns_gitea** | Git repository management (local development environment) | ✅ Yes | [README](ansible/roles/validated_patterns_gitea/README.md) |
| **validated_patterns_secrets** | Secrets management (sealed secrets, RBAC) | ✅ Yes | [README](ansible/roles/validated_patterns_secrets/README.md) |
| **validated_patterns_validate** | Comprehensive validation (pre/post deployment, health checks) | ✅ Yes | [README](ansible/roles/validated_patterns_validate/README.md) |

**See**: [Ansible Roles Reference](docs/ANSIBLE-ROLES-REFERENCE.md) for detailed documentation.

## 📦 Reference Applications

### Included Examples

#### 1. Quarkus REST API (Included)
- **Location**: `quarkus-reference-app/`
- **Purpose**: Example REST API application with Helm charts and Tekton pipelines
- **Documentation**: [Quarkus App README](quarkus-reference-app/README.md)
- **ADR**: [ADR-004: Quarkus Reference Application](docs/adr/ADR-004-quarkus-reference-application.md)

#### 2. OpenShift AI Validation (Infrastructure)
- **Purpose**: Validate RHOAI platform readiness (notebooks, pipelines, model serving)
- **Documentation**: [ADR-009: OpenShift AI Validation](docs/adr/ADR-009-openshift-ai-validation.md)
- **Note**: Validates platform infrastructure, not sample applications

### You Can Deploy

This toolkit supports **any containerized application**:

- ✅ Python Flask/Django applications
- ✅ Node.js applications
- ✅ Spring Boot applications
- ✅ OpenShift AI notebooks and pipelines
- ✅ Machine learning workloads
- ✅ Data processing applications
- ✅ Static websites
- ✅ **Any containerized application**

**Example**: Replace the Quarkus app with your own application:

```bash
# Remove Quarkus app
rm -rf quarkus-reference-app/

# Add your application
cp -r ~/my-app ./my-app/

# Update configuration
vi values-hub.yaml  # Point to your app

# Deploy
ansible-playbook ansible/playbooks/deploy_complete_pattern.yml
```

## 🏗️ Dual-Workflow Architecture

### Development Workflow (Granular Control)
- **Uses**: Roles 1-2, 4-7
- **Audience**: Pattern developers, maintainers, advanced users
- **Guide**: [Developer Guide](docs/DEVELOPER-GUIDE.md)
- **Purpose**: Full control over deployment process

### End-User Workflow (Simplified)
- **Uses**: Role 3 (VP Operator)
- **Audience**: Pattern consumers, production deployments
- **Guide**: [End-User Guide](docs/END-USER-GUIDE.md)
- **Purpose**: Simplified deployment via Validated Patterns Operator

**See**: [Deployment Decision Flowchart](docs/DEPLOYMENT-DECISION-FLOWCHART.md) to choose your workflow.

## 🛠️ Build & Test (Execution Environment)

The toolkit includes an **Execution Environment** (container) for running Ansible roles. This is infrastructure, not the primary focus.

### Quick Build Commands

```bash
# Navigate to repository
cd validated-patterns-ansible-toolkit

# Container engine: Podman is used throughout this repo and CI
# Optionally provision build server using script
./files/provision.sh

# Set your Ansible Hub token
export ANSIBLE_HUB_TOKEN="your-token-here"

# Build the Execution Environment
make clean      # Remove build artifacts
make token      # Verify ANSIBLE_HUB_TOKEN
make build      # Build EE image
make test       # Run playbook with ansible-navigator
make inspect    # Inspect the image
make info       # Review layers and packages
make shell      # (Optional) Look inside the container
make publish    # Publish to registry
```

### Customize Dependencies

Edit these files to customize the Execution Environment:

- **`files/requirements.yml`** - Ansible collections
- **`files/requirements.txt`** - Python packages
- **`files/bindep.txt`** - System packages
- **`execution-environment.yml`** - EE configuration
- **`Makefile`** - Build variables

**See**: [How-To: Troubleshoot EE Builds](docs/how-to/troubleshoot-ee-builds.md) for troubleshooting.

## 🔒 Security

### Pre-commit Hooks with Gitleaks (v1.0)

This repository uses **pre-commit hooks** with **gitleaks** to prevent secrets from being committed:

```bash
# Install pre-commit (if not already installed)
pip install pre-commit

# Install the git hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

**See**: [ADR-014: Pre-commit Hooks and Gitleaks Integration](docs/adr/ADR-014-pre-commit-hooks-gitleaks.md) (to be created)

### Container Image Scanning

Scan your Execution Environment images for vulnerabilities:

- [Using Snyk and Podman to scan container images](https://www.redhat.com/en/blog/using-snyk-and-podman-scan-container-images-development-deployment)
- [DevSecOps: Image scanning using quay.io scanner](https://www.redhat.com/sysadmin/using-quayio-scanner)

### Security Best Practices

The `validated_patterns_secrets` role implements security best practices:

- Sealed secrets management
- RBAC validation
- Network policies
- Secret scanning

**See**: [validated_patterns_secrets README](ansible/roles/validated_patterns_secrets/README.md)

## ✅ Testing & Validation

### Test the Execution Environment

```bash
# Run playbook to test basic operations
ansible-navigator run files/playbook.yml \
  --container-engine podman \
  --execution-environment-image ansible-ee:5.0

# Check configuration
ansible-navigator config \
  --container-engine podman \
  --execution-environment-image ansible-ee:5.0
```

### Test Pattern Deployment

```bash
# Run integration tests
cd tests/integration
ansible-playbook test_complete_deployment.yml

# Run week-specific tests
cd tests/week10
ansible-playbook test_week10_validation.yml
```

**See**: [How-To: Test Your EE](docs/how-to/testing-execution-environment.md) for detailed testing.

## 🤝 Contributing

We welcome contributions! This repository is designed to be:

- **Forked** - Create your own patterns
- **Extended** - Add new roles and applications
- **Improved** - Enhance existing roles and documentation

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** (follow [AGENTS.md](AGENTS.md) for development rules)
4. **Test your changes** (`make build test`)
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### Contribution Ideas

- ✅ Add new Ansible roles (follow [ADR-002](docs/adr/ADR-002-ansible-role-architecture.md))
- ✅ Add new reference applications (Python, Node.js, Spring Boot, etc.)
- ✅ Improve documentation (tutorials, how-tos, examples)
- ✅ Add new validation checks
- ✅ Improve test coverage
- ✅ Fix bugs and issues

**See**: [CONTRIBUTING.md](CONTRIBUTING.md) (to be created in v1.0 release)

## 📋 Requirements

### OpenShift Cluster
- OpenShift 4.12+ (tested on 4.19.16)
- 6+ nodes recommended (tested on AWS)
- Cluster admin access

### Local Tools
- Ansible 2.15+
- Helm 3.12+
- oc CLI
- Podman (for building Execution Environment)
- ansible-navigator (for testing)

### Optional
- Ansible Hub token (for private collections)
- Gitea (for local development)

**See**: [How-To: Enable Kubernetes and OpenShift](docs/how-to/enable-kubernetes-openshift.md)

## 🎓 Learning Resources

### Validated Patterns
- [Validated Patterns Official Site](https://validatedpatterns.io/)
- [Validated Patterns GitHub](https://github.com/validatedpatterns)
- [Pattern Development Guide](https://validatedpatterns.io/learn/quickstart/)

### OpenShift GitOps
- [OpenShift GitOps Documentation](https://docs.openshift.com/gitops/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

### Ansible
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

### Execution Environments
- [What are Automation Execution Environments?](https://www.redhat.com/en/technologies/management/ansible/automation-execution-environments)
- [Ansible Builder Guide](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.1/html/ansible_builder_guide/)
- [Ansible Navigator Documentation](https://ansible.readthedocs.io/projects/navigator/)

## 💡 Tips and Tricks

### Ansible Navigator Commands

```bash
# Examine execution environment
ansible-navigator --eei <image-name>

# Extract list of collections
ansible-navigator --eei <image-name> collections --mode stdout

# Run syntax check
ansible-navigator run <playbook> --syntax-check --mode stdout

# Mount credentials
ansible-navigator run playbook.yml \
  --eev /home/user/creds:/home/user/creds:Z
```

### Podman Commands

```bash
# Start shell session inside container
podman run -it registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest /bin/bash

# With volume mounts
podman run -it -v $PWD:/opt/ansible registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest /bin/bash

# With SELinux volume mounts
podman run -it -v $PWD:/opt/ansible:z registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest /bin/bash

# Run adhoc commands
podman run --rm <image-name> <command>
```

### Ansible Builder Commands

```bash
# Build with verbosity
ansible-builder build --verbosity 3 --container-runtime=podman --tag ansible-ee:5.0

# Inspect build context
ansible-builder create --output-dir /tmp/ee-build
```

### Troubleshooting

#### Find and Test Base Images

```bash
# Login to registry
podman login registry.redhat.io

# Search for images
podman search registry.redhat.io/ansible-automation-platform-25

# Pull and test
podman run -it -v $PWD:/opt/ansible \
  registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest /bin/bash

# Check dependencies
ansible-galaxy collection install -r requirements.yml
pip3 install -r requirements.txt
```

#### Customize Base Images (Private Mirrors)

```bash
# Create custom yum repo
cat > ubi.repo <<EOF
[rhel-8-for-x86_64-appstream-rpms]
baseurl = http://mirror.example.com/rpms/rhel-8-for-x86_64-appstream-rpms
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
EOF

# Create custom pip config
cat > pip.conf <<EOF
[global]
index-url = https://artifactory.example.com/artifactory/api/pypi/pypi/simple
trusted-host = artifactory.example.com
EOF

# Customize and commit
podman run -d -it --name custom-ee \
  registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest /bin/bash
podman cp ubi.repo custom-ee:/etc/yum.repos.d/
podman cp pip.conf custom-ee:/etc/
podman commit custom-ee custom-ee:latest
```

**See**: [Troubleshooting Guide](docs/TROUBLESHOOTING-COMPREHENSIVE.md) for more details.

## 🔗 Additional Resources

### Ansible Collections

- [Ansible Automation Platform Certified Content](https://access.redhat.com/support/articles/ansible-automation-platform-certified-content)
- [Red Hat Automation Hub](https://console.redhat.com/ansible/automation-hub)
- [Ansible Galaxy](https://galaxy.ansible.com/search?)

### Common Issues

- [kubernetes.core requires openshift-clients](https://access.redhat.com/solutions/6985157)
- [Installing OpenShift CLI via RPM](https://docs.openshift.com/container-platform/4.13/cli_reference/openshift_cli/getting-started-cli.html#cli-installing-cli-rpm_cli-developer-commands)
- [Python dependency checking with johnnydep](https://pypi.org/project/johnnydep/)

### Best Practices

- [Multi-architecture container images](https://developers.redhat.com/articles/2023/11/03/how-build-multi-architecture-container-images)
- [Red Hat Container Certification](https://developers.redhat.com/articles/2021/11/11/best-practices-building-images-pass-red-hat-container-certification)
- [DevSecOps Best Practices](https://developers.redhat.com/articles/2022/06/15/best-practices-successful-devsecops)

### Tools Documentation

- **ansible-builder**: [Docs](https://ansible-builder.readthedocs.io/) | [Source](https://github.com/ansible/ansible-builder)
- **ansible-navigator**: [Docs](https://ansible.readthedocs.io/projects/navigator/) | [Source](https://github.com/ansible/ansible-navigator/)
- **podman**: [Docs](https://podman.io/) | [Installation](https://podman.io/getting-started/installation)
- **buildah**: [Source](https://github.com/containers/buildah)
- **skopeo**: [Source](https://github.com/containers/skopeo)

## 📊 Project Status

### Current Phase
- **Phase 4**: Documentation & Release (Week 12-16)
- **Completion**: 50% (8 of 16 weeks complete)
- **Status**: Ready for v1.0 release

### Completed
- ✅ 7 production-ready Ansible roles (3,460+ LOC)
- ✅ Quarkus reference application (30 files, 1,200+ LOC)
- ✅ Tekton CI/CD pipelines
- ✅ Comprehensive test suite (3,000+ LOC)
- ✅ Complete Diataxis documentation (50+ files)
- ✅ 13 Architectural Decision Records (ADRs)
- ✅ Multi-environment support (dev/prod)
- ✅ Security validation (RBAC, secrets, network policies)

### In Progress (v1.0 Release)
- 🔄 Repository migration (Gitea → GitHub)
- 🔄 Pre-commit hooks with gitleaks
- 🔄 Community health files (CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, SUPPORT)
- 🔄 Reusability documentation
- 🔄 Final testing and validation

**See**: [Implementation Plan](docs/IMPLEMENTATION-PLAN.md) for detailed status.

## 📝 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

### What This Means for You

The GPL v3.0 license is **designed to protect your freedom** to use, study, share, and improve this software.

✅ **You CAN**:
- ✅ **Copy** this entire repository for your own use
- ✅ **Fork** the repository and make it your own
- ✅ **Modify** the code to fit your needs
- ✅ **Extract** individual Ansible roles into your projects
- ✅ **Distribute** the code (original or modified)
- ✅ **Use commercially** in your organization
- ✅ **Create private deployments** without sharing your changes

✅ **You MUST** (only if you distribute):
- 📄 Include the original license and copyright notice
- 📝 State what changes you made (if any)
- 🔓 Make your source code available (if you distribute)
- ⚖️ Use the same GPL v3.0 license for derivatives (if you distribute)

### Common Use Cases

**✅ Allowed without restrictions:**
- Clone and deploy in your organization (no distribution = no obligations)
- Extract roles into your private projects
- Modify for your internal use
- Learn from the code and examples

**✅ Allowed with GPL v3.0 compliance:**
- Fork and create your own public pattern repository
- Distribute modified versions to others
- Create a commercial product based on this code (must be GPL v3.0)

**See**:
- [GNU GPL v3.0 Full Text](https://www.gnu.org/licenses/gpl-3.0.html)
- [GNU GPL v3.0 FAQ](https://www.gnu.org/licenses/gpl-faq.html)
- [Quick Guide to GPLv3](https://www.gnu.org/licenses/quick-guide-gplv3.html)

## 👥 Authors & Acknowledgments

### Original Author
- **John Wadleigh** - Original Execution Environment repository

### Current Maintainer
- **Tosin Akinosho** (@tosin2013) - Validated Patterns Toolkit

### Contributors
- See [GitHub Contributors](https://github.com/tosin2013/validated-patterns-ansible-toolkit/graphs/contributors)

### Acknowledgments
- [Validated Patterns Community](https://validatedpatterns.io/)
- [Red Hat Communities of Practice](https://github.com/redhat-cop)
- [Ansible Community](https://www.ansible.com/community)

## 📞 Support & Community

### Get Help
- **Documentation**: [SUPPORT.md](SUPPORT.md) - Comprehensive support guide
- **Issues**: [GitHub Issues](https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues) - Bug reports and feature requests
- **Discussions**: [GitHub Discussions](https://github.com/tosin2013/validated-patterns-ansible-toolkit/discussions) - Questions and community discussions
- **Guides**: [docs/](docs/) - Comprehensive documentation

### Contributing
- **Contributing Guide**: [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- **Code of Conduct**: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community standards
- **Pre-commit Setup**: [docs/CONTRIBUTING-PRE-COMMIT.md](docs/CONTRIBUTING-PRE-COMMIT.md) - Developer setup

### Community
- **Validated Patterns**: [validatedpatterns.io](https://validatedpatterns.io/)
- **Red Hat Communities**: [github.com/redhat-cop](https://github.com/redhat-cop)

### Security
- **Security Policy**: [SECURITY.md](SECURITY.md) - Vulnerability reporting and security practices
- **Pre-commit Hooks**: Gitleaks for secret scanning (8 custom rules)
- **Security Advisory**: [SECURITY-ADVISORY-001](docs/SECURITY-ADVISORY-001-EXPOSED-GITEA-TOKEN.md) - Resolved incidents

---

## 🚀 Quick Links

- **[Release Plan](docs/RELEASE-PLAN.md)** - v1.0 release plan
- **[Quick Reference](docs/RELEASE-QUICK-REFERENCE.md)** - Quick reference card
- **[Developer Guide](docs/DEVELOPER-GUIDE.md)** - Development workflow
- **[End-User Guide](docs/END-USER-GUIDE.md)** - End-user workflow
- **[Ansible Roles Reference](docs/ANSIBLE-ROLES-REFERENCE.md)** - Roles documentation
- **[Architecture Diagrams](docs/ARCHITECTURE-DIAGRAMS.md)** - Visual architecture
- **[ADRs](docs/adr/)** - Architectural decisions
- **[Troubleshooting](docs/TROUBLESHOOTING-COMPREHENSIVE.md)** - Troubleshooting guide

---

**Made with ❤️ by the Validated Patterns Community**
