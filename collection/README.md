# Ansible Collection - tosin2013.validated_patterns_toolkit

[![License](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](https://github.com/tosin2013/validated-patterns-ansible-toolkit/blob/main/LICENSE)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-tosin2013.validated__patterns__toolkit-blue.svg)](https://galaxy.ansible.com/tosin2013/validated_patterns_toolkit)
[![GitHub](https://img.shields.io/github/stars/tosin2013/validated-patterns-ansible-toolkit?style=social)](https://github.com/tosin2013/validated-patterns-ansible-toolkit)

Production-ready Ansible collection for deploying [Red Hat Validated Patterns](https://validatedpatterns.io/) on OpenShift using GitOps principles.

## 📋 Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Roles](#roles)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Variables](#variables)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)
- [Contributing](#contributing)

## 🎯 Overview

This collection provides 8 production-ready Ansible roles for deploying Validated Patterns on OpenShift clusters. It automates the entire deployment lifecycle from prerequisites validation to pattern deployment and validation.

**Key Features:**
- ✅ Automated prerequisites validation
- ✅ GitOps-based deployment with ArgoCD
- ✅ Sealed Secrets management
- ✅ Gitea operator integration
- ✅ Pattern validation and health checks
- ✅ Complete cleanup capabilities
- ✅ Comprehensive error handling
- ✅ Idempotent operations

## 📦 Requirements

### Ansible Version
- Ansible Core: `>= 2.15.0`

### Collections
- `kubernetes.core` >= 2.3.0
- `community.general` >= 5.0.0

### Python Dependencies
- `kubernetes` >= 12.0.0
- `openshift` >= 0.12.0
- `PyYAML` >= 5.4.1

### OpenShift Cluster
- OpenShift 4.12+ or OCP 4.12+
- Cluster admin access
- Minimum 3 worker nodes
- 16 vCPUs, 32GB RAM per node (recommended)

## 🚀 Installation

### Method 1: Install from Ansible Galaxy (Recommended)

```bash
ansible-galaxy collection install tosin2013.validated_patterns_toolkit
```

### Method 2: Install from requirements.yml

Create a `requirements.yml` file:

```yaml
---
collections:
  - name: tosin2013.validated_patterns_toolkit
    version: ">=1.0.0"
  - name: kubernetes.core
    version: ">=2.3.0"
  - name: community.general
    version: ">=5.0.0"
```

Install the collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

### Method 3: Install from GitHub

```bash
ansible-galaxy collection install git+https://github.com/tosin2013/validated-patterns-ansible-toolkit.git,main
```

## 🔧 Roles

This collection includes 8 roles for complete Validated Patterns deployment:

### 1. `prerequisites`
Validates OpenShift cluster prerequisites before deployment.

**Key Tasks:**
- Check OpenShift version compatibility
- Validate cluster resources (CPU, memory, storage)
- Verify network connectivity
- Check RBAC permissions
- Validate required operators

**Usage:**
```yaml
- name: Validate prerequisites
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.prerequisites
```

### 2. `common`
Common tasks for Validated Patterns deployment including Helm repository configuration.

**Key Tasks:**
- Configure Helm repositories
- Deploy clustergroup Helm charts
- Install required collections
- Setup common resources

**Usage:**
```yaml
- name: Setup common resources
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.common
  vars:
    helm_repos:
      - name: validated-patterns
        url: https://charts.validatedpatterns.io/
```

### 3. `operator`
Installs and configures the Validated Patterns Operator.

**Key Tasks:**
- Install Validated Patterns Operator via OLM
- Create Pattern Custom Resource
- Wait for GitOps components
- Validate operator deployment

**Usage:**
```yaml
- name: Install Validated Patterns Operator
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.operator
  vars:
    pattern_name: "my-pattern"
    pattern_repo: "https://github.com/myorg/my-pattern.git"
```

### 4. `deploy`
Deploys Validated Patterns with ArgoCD configuration.

**Key Tasks:**
- Configure ArgoCD for pattern deployment
- Deploy pattern applications
- Validate pattern deployment
- Verify deployment health

**Usage:**
```yaml
- name: Deploy Validated Pattern
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.deploy
  vars:
    pattern_name: "industrial-edge"
    target_branch: "main"
```

### 5. `gitea`
Deploys and configures Gitea operator with repositories and users.

**Key Tasks:**
- Deploy Gitea operator
- Create Gitea instance
- Configure users and organizations
- Setup pattern repositories

**Usage:**
```yaml
- name: Setup Gitea
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.gitea
  vars:
    gitea_admin_user: "admin"
    gitea_admin_password: "{{ vault_gitea_password }}"
```

### 6. `secrets`
Manages secrets using Sealed Secrets for GitOps workflows.

**Key Tasks:**
- Install Sealed Secrets operator
- Setup encryption keys
- Manage credentials
- Validate secret encryption

**Usage:**
```yaml
- name: Manage secrets
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.secrets
  vars:
    sealed_secrets_namespace: "sealed-secrets"
```

### 7. `validate`
Validates Validated Patterns deployment health and performs post-deployment checks.

**Key Tasks:**
- Pre-deployment validation
- Post-deployment health checks
- ArgoCD application status
- Pattern component validation

**Usage:**
```yaml
- name: Validate deployment
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.validate
  vars:
    pattern_name: "industrial-edge"
```

### 8. `cleanup`
Cleans up Validated Patterns deployment resources and operators.

**Key Tasks:**
- Remove pattern applications
- Uninstall operators
- Clean up namespaces
- Remove custom resources

**Usage:**
```yaml
- name: Cleanup pattern
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.cleanup
  vars:
    pattern_name: "industrial-edge"
    cleanup_operators: true
```

## 🚀 Quick Start

### Complete Pattern Deployment

```yaml
---
- name: Deploy Validated Pattern
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    pattern_name: "industrial-edge"
    pattern_repo: "https://github.com/validatedpatterns/industrial-edge.git"
    pattern_branch: "main"
    target_namespace: "openshift-gitops"

  tasks:
    - name: Validate prerequisites
      ansible.builtin.include_role:
        name: tosin2013.validated_patterns_toolkit.prerequisites

    - name: Setup common resources
      ansible.builtin.include_role:
        name: tosin2013.validated_patterns_toolkit.common

    - name: Install Validated Patterns Operator
      ansible.builtin.include_role:
        name: tosin2013.validated_patterns_toolkit.operator

    - name: Deploy pattern
      ansible.builtin.include_role:
        name: tosin2013.validated_patterns_toolkit.deploy

    - name: Setup secrets management
      ansible.builtin.include_role:
        name: tosin2013.validated_patterns_toolkit.secrets

    - name: Validate deployment
      ansible.builtin.include_role:
        name: tosin2013.validated_patterns_toolkit.validate
```

Run the playbook:

```bash
ansible-playbook deploy_pattern.yml
```
## 📚 Usage Examples

### Example 1: Prerequisites Check Only

```yaml
---
- name: Check cluster prerequisites
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.prerequisites
  vars:
    check_only: true
    fail_on_error: false
```

### Example 2: Deploy with Gitea

```yaml
---
- name: Deploy pattern with Gitea
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.prerequisites
    - tosin2013.validated_patterns_toolkit.common
    - tosin2013.validated_patterns_toolkit.gitea
    - tosin2013.validated_patterns_toolkit.operator
    - tosin2013.validated_patterns_toolkit.deploy
  vars:
    pattern_name: "multicloud-gitops"
    use_gitea: true
    gitea_admin_user: "admin"
```

### Example 3: Cleanup Deployment

```yaml
---
- name: Remove pattern deployment
  hosts: localhost
  roles:
    - tosin2013.validated_patterns_toolkit.cleanup
  vars:
    pattern_name: "industrial-edge"
    cleanup_operators: true
    cleanup_namespaces: true
```

## 🔐 Variables

### Global Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `pattern_name` | `""` | Name of the Validated Pattern to deploy |
| `pattern_repo` | `""` | Git repository URL for the pattern |
| `pattern_branch` | `main` | Git branch to use |
| `target_namespace` | `openshift-gitops` | Namespace for GitOps components |
| `kubeconfig_path` | `~/.kube/config` | Path to kubeconfig file |

### Prerequisites Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `min_openshift_version` | `4.12` | Minimum OpenShift version required |
| `min_worker_nodes` | `3` | Minimum number of worker nodes |
| `min_cpu_per_node` | `8` | Minimum vCPUs per node |
| `min_memory_per_node` | `16` | Minimum memory (GB) per node |
| `check_only` | `false` | Only check prerequisites without failing |

### Operator Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `operator_namespace` | `openshift-operators` | Namespace for operator installation |
| `operator_channel` | `stable` | Operator subscription channel |
| `wait_for_operator` | `true` | Wait for operator to be ready |
| `operator_timeout` | `600` | Timeout in seconds for operator readiness |

### Deploy Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `argocd_namespace` | `openshift-gitops` | ArgoCD namespace |
| `sync_policy` | `automated` | ArgoCD sync policy (automated/manual) |
| `self_heal` | `true` | Enable ArgoCD self-healing |
| `prune_resources` | `true` | Enable resource pruning |

### Gitea Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `gitea_namespace` | `gitea` | Namespace for Gitea deployment |
| `gitea_admin_user` | `gitea-admin` | Gitea admin username |
| `gitea_admin_password` | `""` | Gitea admin password (use vault) |
| `gitea_create_repos` | `true` | Automatically create repositories |

### Secrets Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `sealed_secrets_namespace` | `sealed-secrets` | Sealed Secrets namespace |
| `sealed_secrets_version` | `latest` | Sealed Secrets version |
| `manage_credentials` | `true` | Manage pattern credentials |

## 📦 Dependencies

This collection depends on the following Ansible collections:

- `kubernetes.core` (>= 2.3.0) - Kubernetes/OpenShift resource management
- `community.general` (>= 5.0.0) - General-purpose modules

Install dependencies:

```bash
ansible-galaxy collection install -r requirements.yml
```

## 📄 License

GPL-3.0-or-later

See [LICENSE](https://github.com/tosin2013/validated-patterns-ansible-toolkit/blob/main/LICENSE) for full details.

## 👤 Author

**Tosin Akinosho**
- GitHub: [@tosin2013](https://github.com/tosin2013)
- Email: tosin.akinosho@gmail.com

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](https://github.com/tosin2013/validated-patterns-ansible-toolkit/blob/main/CONTRIBUTING.md) for details.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🐛 Issues

Report issues at: https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues

## 📚 Additional Resources

- [Validated Patterns Documentation](https://validatedpatterns.io/)
- [Red Hat Validated Patterns](https://github.com/validatedpatterns)
- [OpenShift GitOps](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

## 🙏 Acknowledgments

- Red Hat Validated Patterns Team
- OpenShift GitOps Community
- Ansible Community

---

**Note**: This collection is part of the [Validated Patterns Ansible Toolkit](https://github.com/tosin2013/validated-patterns-ansible-toolkit) project.

