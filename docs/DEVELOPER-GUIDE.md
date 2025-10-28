# Developer Guide - Validated Patterns Toolkit

**Audience:** Pattern developers who need full control over pattern development and deployment
**Workflow:** Development Roles (Roles 1-2, 4-7)
**Version:** 1.0
**Last Updated:** 2025-10-27

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Development Workflow](#development-workflow)
4. [Role-by-Role Guide](#role-by-role-guide)
5. [Complete Example](#complete-example)
6. [Testing and Validation](#testing-and-validation)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Overview

### What is the Development Workflow?

The development workflow uses **6 Ansible roles** that provide granular control over pattern deployment. This workflow is designed for:

- **Pattern Developers:** Creating new validated patterns
- **Pattern Maintainers:** Updating existing patterns
- **Advanced Users:** Requiring customization and control
- **CI/CD Integration:** Automated testing and deployment

### Development Roles Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Development Workflow                      │
│                  (6 Roles - Full Control)                    │
└─────────────────────────────────────────────────────────────┘

Role 1: validated_patterns_prerequisites
  ↓ Validates cluster readiness

Role 2: validated_patterns_common
  ↓ Deploys common infrastructure (Helm, ArgoCD)

Role 4: validated_patterns_deploy
  ↓ Deploys pattern applications

Role 5: validated_patterns_gitea
  ↓ Sets up Gitea for local development

Role 6: validated_patterns_secrets
  ↓ Manages secrets and encryption

Role 7: validated_patterns_validate
  ↓ Validates deployment health
```

### When to Use Development Workflow

✅ **Use Development Workflow When:**
- Developing a new validated pattern
- Testing pattern changes locally
- Debugging pattern deployment issues
- Customizing pattern behavior
- Integrating with CI/CD pipelines
- Learning pattern internals

❌ **Don't Use Development Workflow When:**
- Simply deploying an existing pattern (use [End-User Guide](END-USER-GUIDE.md))
- Production deployment without customization
- Quick pattern evaluation

---

## Prerequisites

### Required Tools

```bash
# OpenShift CLI
oc version
# Client Version: 4.12+

# Ansible
ansible --version
# ansible [core 2.15+]

# Ansible Navigator (recommended)
ansible-navigator --version
# ansible-navigator 3.0+

# Helm
helm version
# version.BuildInfo{Version:"v3.12+"}

# Git
git --version
# git version 2.30+
```

### Required Collections

```bash
# Install required Ansible collections
ansible-galaxy collection install -r files/requirements.yml

# Verify installation
ansible-galaxy collection list | grep -E "kubernetes|community"
```

### Cluster Access

```bash
# Login to OpenShift cluster
oc login <cluster-url> -u <username> -p <password>

# Verify cluster access
oc whoami
oc cluster-info

# Verify cluster-admin permissions (required)
oc auth can-i create namespaces
# yes
```

### Environment Setup

```bash
# Clone the repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# Set up environment variables (optional)
export KUBECONFIG=/path/to/kubeconfig
export ANSIBLE_CONFIG=ansible.cfg
```

---

## Development Workflow

### Step-by-Step Process

#### 1. Validate Prerequisites

**Purpose:** Ensure cluster meets all requirements before deployment

```bash
# Using ansible-navigator (recommended)
ansible-navigator run ansible/playbooks/test_prerequisites.yml

# Using ansible-playbook
ansible-playbook ansible/playbooks/test_prerequisites.yml
```

**What Gets Checked:**
- ✅ OpenShift version (4.12+)
- ✅ Required operators (GitOps)
- ✅ Cluster resources (CPU, memory, nodes)
- ✅ Network connectivity
- ✅ RBAC permissions
- ✅ Storage configuration

**Expected Output:**
```
TASK [validated_patterns_prerequisites : Display validation results]
ok: [localhost] => {
    "msg": [
        "✅ OpenShift version: 4.19.16",
        "✅ GitOps operator: v1.18.1",
        "✅ Cluster resources: 16 CPU, 64GB RAM, 3 nodes",
        "✅ All prerequisites met"
    ]
}
```

#### 2. Deploy Common Infrastructure

**Purpose:** Install Helm, configure repositories, deploy ArgoCD

```bash
# Deploy common infrastructure
ansible-navigator run ansible/playbooks/install_gitops.yml

# Or with custom variables
ansible-navigator run ansible/playbooks/install_gitops.yml \
  -e validated_patterns_pattern_name=my-pattern \
  -e validated_patterns_target_revision=main
```

**What Gets Deployed:**
- ✅ rhvp.cluster_utils Ansible collection
- ✅ Helm v3.19+ configured
- ✅ Helm repositories (validatedpatterns, jetstack, external-secrets)
- ✅ ArgoCD in openshift-gitops namespace
- ✅ clustergroup-chart v0.9.*

**Verification:**
```bash
# Check Helm installation
helm version

# Check Helm repositories
helm repo list

# Check ArgoCD deployment
oc get pods -n openshift-gitops
# NAME                                                          READY   STATUS
# openshift-gitops-application-controller-0                     1/1     Running
# openshift-gitops-applicationset-controller-xxx                1/1     Running
# openshift-gitops-redis-xxx                                    1/1     Running
# openshift-gitops-repo-server-xxx                              1/1     Running
# openshift-gitops-server-xxx                                   1/1     Running
```

#### 3. Deploy Pattern Applications

**Purpose:** Deploy your pattern's applications using ArgoCD

```bash
# Deploy complete pattern
ansible-navigator run ansible/playbooks/deploy_complete_pattern.yml \
  -e validated_patterns_pattern_name=my-pattern \
  -e validated_patterns_repo_url=https://github.com/myorg/my-pattern.git \
  -e validated_patterns_target_revision=main
```

**What Gets Deployed:**
- ✅ Pattern namespace created
- ✅ ArgoCD Application CR created
- ✅ Pattern applications synced
- ✅ All resources deployed

**Verification:**
```bash
# Check ArgoCD applications
oc get applications -n openshift-gitops

# Check pattern namespace
oc get all -n <pattern-namespace>

# Access ArgoCD UI
oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}'
```

#### 4. Set Up Local Development (Optional)

**Purpose:** Deploy Gitea for local pattern development

```bash
# Deploy Gitea
ansible-playbook ansible/roles/validated_patterns_gitea/tests/test.yml
```

**What Gets Deployed:**
- ✅ Gitea instance in gitea namespace
- ✅ PostgreSQL database
- ✅ Persistent storage
- ✅ Route for web access

**Access Gitea:**
```bash
# Get Gitea URL
oc get route gitea -n gitea -o jsonpath='{.spec.host}'

# Default credentials
# Username: gitea_admin
# Password: <check secret>
oc get secret gitea-admin-secret -n gitea -o jsonpath='{.data.password}' | base64 -d
```

#### 5. Manage Secrets

**Purpose:** Handle secrets and sensitive configuration

```bash
# Deploy secrets management
ansible-playbook ansible/roles/validated_patterns_secrets/tests/test.yml \
  -e validated_patterns_secrets_namespace=validated-patterns-secrets
```

**What Gets Deployed:**
- ✅ Dedicated secrets namespace
- ✅ RBAC for secrets access
- ✅ Secret encryption configuration
- ✅ External secrets operator (optional)

**Managing Secrets:**
```bash
# Create a secret
oc create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123 \
  -n validated-patterns-secrets

# Use Sealed Secrets (if available)
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
oc apply -f sealed-secret.yaml
```

#### 6. Validate Deployment

**Purpose:** Comprehensive validation of pattern deployment

```bash
# Run validation
ansible-playbook ansible/roles/validated_patterns_validate/tests/test.yml
```

**What Gets Validated:**
- ✅ Pre-deployment checks
- ✅ Deployment status
- ✅ Post-deployment verification
- ✅ Health checks
- ✅ ArgoCD sync status
- ✅ Application availability

---

## Role-by-Role Guide

### Role 1: validated_patterns_prerequisites

**Purpose:** Validate cluster readiness

**Key Variables:**
```yaml
validated_patterns_min_openshift_version: "4.12"
validated_patterns_min_nodes: 3
validated_patterns_min_cpu: 8  # cores
validated_patterns_min_memory: 16  # GB
validated_patterns_required_operators:
  - openshift-gitops-operator
```

**Usage:**
```yaml
---
- name: Validate prerequisites
  hosts: localhost
  gather_facts: no
  roles:
    - validated_patterns_prerequisites
```

**Customization:**
```yaml
# Require more resources
- hosts: localhost
  roles:
    - role: validated_patterns_prerequisites
      vars:
        validated_patterns_min_nodes: 5
        validated_patterns_min_cpu: 16
        validated_patterns_min_memory: 32
```

### Role 2: validated_patterns_common

**Purpose:** Deploy common infrastructure

**Key Variables:**
```yaml
validated_patterns_rhvp_collection_version: "1.0.0"
validated_patterns_clustergroup_chart_version: "0.9.*"
validated_patterns_pattern_name: "my-pattern"
validated_patterns_target_revision: "main"
validated_patterns_multisource_enabled: true
```

**Usage:**
```yaml
---
- name: Deploy common infrastructure
  hosts: localhost
  gather_facts: no
  roles:
    - validated_patterns_common
```

**What It Does:**
1. Installs rhvp.cluster_utils collection
2. Configures Helm repositories
3. Deploys clustergroup-chart
4. Enables multisource configuration

### Role 4: validated_patterns_deploy

**Purpose:** Deploy pattern applications

**Key Variables:**
```yaml
validated_patterns_pattern_name: "my-pattern"
validated_patterns_repo_url: "https://github.com/myorg/my-pattern.git"
validated_patterns_target_revision: "main"
validated_patterns_namespace: "my-pattern"
validated_patterns_sync_timeout: 300
validated_patterns_auto_sync: true
```

**Usage:**
```yaml
---
- name: Deploy pattern
  hosts: localhost
  gather_facts: no
  vars:
    validated_patterns_pattern_name: "quarkus-app"
    validated_patterns_repo_url: "https://github.com/myorg/quarkus-app.git"
  roles:
    - validated_patterns_deploy
```

### Role 5: validated_patterns_gitea

**Purpose:** Local development environment

**Key Variables:**
```yaml
gitea_namespace: "gitea"
gitea_admin_user: "gitea_admin"
gitea_admin_password: "changeme"
gitea_storage_size: "10Gi"
```

**Usage:**
```yaml
---
- name: Deploy Gitea
  hosts: localhost
  gather_facts: no
  roles:
    - validated_patterns_gitea
```

**Use Cases:**
- Local pattern development
- Testing without external Git
- Air-gapped environments
- CI/CD testing

### Role 6: validated_patterns_secrets

**Purpose:** Secrets management

**Key Variables:**
```yaml
validated_patterns_secrets_namespace: "validated-patterns-secrets"
validated_patterns_use_sealed_secrets: true
validated_patterns_use_external_secrets: false
```

**Usage:**
```yaml
---
- name: Manage secrets
  hosts: localhost
  gather_facts: no
  roles:
    - validated_patterns_secrets
```

**Best Practices:**
- Use dedicated secrets namespace
- Enable RBAC for secrets access
- Consider Sealed Secrets for GitOps
- Never commit secrets to Git

### Role 7: validated_patterns_validate

**Purpose:** Deployment validation

**Key Variables:**
```yaml
validated_patterns_namespace: "my-pattern"
validated_patterns_validation_timeout: 300
validated_patterns_validate_pre_deployment: true
validated_patterns_validate_deployment: true
validated_patterns_validate_post_deployment: true
validated_patterns_validate_health: true
```

**Usage:**
```yaml
---
- name: Validate deployment
  hosts: localhost
  gather_facts: no
  roles:
    - validated_patterns_validate
```

---

## Complete Example

### Deploying the Quarkus Reference Application

This example demonstrates the complete development workflow using the Quarkus reference application.

#### Step 1: Prepare Environment

```bash
# Clone repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# Login to OpenShift
oc login <cluster-url>

# Verify access
oc whoami
oc auth can-i create namespaces
```

#### Step 2: Create Playbook

Create `deploy_quarkus_dev.yml`:

```yaml
---
- name: Deploy Quarkus Reference App (Development Workflow)
  hosts: localhost
  connection: local
  gather_facts: yes

  vars:
    # Pattern configuration
    validated_patterns_pattern_name: "quarkus-reference-app"
    validated_patterns_repo_url: "https://github.com/tosin2013/validated-patterns-ansible-toolkit.git"
    validated_patterns_target_revision: "main"
    validated_patterns_namespace: "reference-app"

    # Resource requirements
    validated_patterns_min_nodes: 3
    validated_patterns_min_cpu: 8
    validated_patterns_min_memory: 16

  tasks:
    - name: Step 1 - Validate Prerequisites
      include_role:
        name: validated_patterns_prerequisites
      tags: [prerequisites, validate]

    - name: Step 2 - Deploy Common Infrastructure
      include_role:
        name: validated_patterns_common
      tags: [common, infrastructure]

    - name: Step 3 - Deploy Pattern
      include_role:
        name: validated_patterns_deploy
      vars:
        validated_patterns_pattern_path: "quarkus-reference-app"
      tags: [deploy, pattern]

    - name: Step 4 - Validate Deployment
      include_role:
        name: validated_patterns_validate
      tags: [validate, health]

    - name: Display deployment information
      debug:
        msg:
          - "✅ Quarkus Reference App deployed successfully!"
          - "Namespace: {{ validated_patterns_namespace }}"
          - "ArgoCD UI: https://{{ argocd_route }}"
          - "Application URL: https://{{ app_route }}"
      tags: [always]
```

#### Step 3: Run Deployment

```bash
# Run complete deployment
ansible-navigator run deploy_quarkus_dev.yml

# Or run specific steps
ansible-navigator run deploy_quarkus_dev.yml --tags prerequisites
ansible-navigator run deploy_quarkus_dev.yml --tags common
ansible-navigator run deploy_quarkus_dev.yml --tags deploy
ansible-navigator run deploy_quarkus_dev.yml --tags validate
```

#### Step 4: Verify Deployment

```bash
# Check ArgoCD applications
oc get applications -n openshift-gitops

# Check application pods
oc get pods -n reference-app

# Check application route
oc get route -n reference-app

# Test application
curl https://$(oc get route reference-app -n reference-app -o jsonpath='{.spec.host}')/hello
```

#### Step 5: Access ArgoCD UI

```bash
# Get ArgoCD URL
ARGOCD_URL=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
echo "ArgoCD UI: https://$ARGOCD_URL"

# Get admin password
ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d)
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"

# Open in browser
open "https://$ARGOCD_URL"
```

---

## Testing and Validation

### Running Tests

The project includes comprehensive tests for all roles:

```bash
# Test all roles
cd tests/week8
./run_all_tests.sh

# Test specific role
ansible-playbook test_prerequisites.yml
ansible-playbook test_common.yml
ansible-playbook test_deploy.yml
```

### Multi-Environment Testing

```bash
# Test dev overlay
cd tests/week10/multi-environment
ansible-playbook -i ../inventory test_dev_overlay.yml

# Test prod overlay
ansible-playbook -i ../inventory test_prod_overlay.yml

# Run all multi-environment tests
./run_multi_env_tests.sh
```

### Security Validation

```bash
# Run security tests
cd tests/week10/security
./run_security_tests.sh

# Or run individual tests
ansible-playbook -i ../inventory test_security_best_practices.yml
ansible-playbook -i ../inventory test_rbac.yml
ansible-playbook -i ../inventory test_secrets.yml
ansible-playbook -i ../inventory test_network_policies.yml
```

---

## Troubleshooting

### Common Issues

#### 1. Prerequisites Check Fails

**Problem:** OpenShift version check fails

```bash
# Check actual version
oc version

# Override version check (not recommended)
ansible-playbook playbook.yml -e validated_patterns_min_openshift_version="4.10"
```

#### 2. Helm Installation Fails

**Problem:** Helm not found or wrong version

```bash
# Install Helm manually
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

#### 3. ArgoCD Not Deploying

**Problem:** ArgoCD pods not starting

```bash
# Check GitOps operator
oc get csv -n openshift-gitops | grep gitops

# Check ArgoCD instance
oc get argocd -n openshift-gitops

# Check pod logs
oc logs -n openshift-gitops -l app.kubernetes.io/name=openshift-gitops-server
```

#### 4. Pattern Sync Fails

**Problem:** ArgoCD application not syncing

```bash
# Check application status
oc get application -n openshift-gitops

# Describe application
oc describe application <app-name> -n openshift-gitops

# Manual sync
oc patch application <app-name> -n openshift-gitops \
  --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'
```

#### 5. Secrets Not Working

**Problem:** Secrets not accessible

```bash
# Check secrets namespace
oc get secrets -n validated-patterns-secrets

# Check RBAC
oc auth can-i get secrets -n validated-patterns-secrets

# Check secret content
oc get secret <secret-name> -n validated-patterns-secrets -o yaml
```

### Debug Mode

Enable debug mode for detailed output:

```yaml
---
- name: Deploy with debug
  hosts: localhost
  vars:
    ansible_verbosity: 2
    validated_patterns_debug: true
  roles:
    - validated_patterns_deploy
```

Or use ansible-navigator:

```bash
ansible-navigator run playbook.yml -vv
```

### Getting Help

1. **Check Logs:**
   ```bash
   # ArgoCD logs
   oc logs -n openshift-gitops -l app.kubernetes.io/name=openshift-gitops-server

   # Application logs
   oc logs -n <namespace> -l app=<app-name>
   ```

2. **Check Events:**
   ```bash
   oc get events -n <namespace> --sort-by='.lastTimestamp'
   ```

3. **Check Resources:**
   ```bash
   oc get all -n <namespace>
   oc describe pod <pod-name> -n <namespace>
   ```

4. **Community Support:**
   - GitHub Issues: https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues
   - Red Hat Validated Patterns: https://validatedpatterns.io

---

## Best Practices

### 1. Version Control

```bash
# Always use version control for patterns
git init my-pattern
cd my-pattern

# Create .gitignore
cat > .gitignore << EOF
*.retry
.ansible/
secrets/
*.secret
EOF

# Commit pattern files
git add .
git commit -m "Initial pattern commit"
```

### 2. Secrets Management

```yaml
# Never commit secrets to Git
# Use Sealed Secrets or External Secrets Operator

# Example: Using Sealed Secrets
- name: Create sealed secret
  shell: |
    echo -n "my-secret-value" | \
    kubectl create secret generic my-secret \
      --dry-run=client \
      --from-file=password=/dev/stdin \
      -o yaml | \
    kubeseal -o yaml > sealed-secret.yaml
```

### 3. Testing

```yaml
# Always test in dev environment first
- name: Deploy to dev
  hosts: localhost
  vars:
    validated_patterns_namespace: "my-pattern-dev"
    validated_patterns_target_revision: "develop"
  roles:
    - validated_patterns_deploy

# Then promote to prod
- name: Deploy to prod
  hosts: localhost
  vars:
    validated_patterns_namespace: "my-pattern-prod"
    validated_patterns_target_revision: "main"
  roles:
    - validated_patterns_deploy
```

### 4. Idempotency

```yaml
# Ensure playbooks are idempotent
- name: Deploy pattern (idempotent)
  kubernetes.core.k8s:
    state: present
    definition: "{{ lookup('file', 'manifest.yaml') }}"
  register: result
  changed_when: result.changed
```

### 5. Documentation

```yaml
# Document your pattern
# Create README.md with:
# - Purpose
# - Prerequisites
# - Installation steps
# - Configuration options
# - Troubleshooting

# Example pattern README.md
cat > README.md << EOF
# My Pattern

## Purpose
This pattern deploys...

## Prerequisites
- OpenShift 4.12+
- cluster-admin access

## Installation
\`\`\`bash
ansible-navigator run deploy.yml
\`\`\`

## Configuration
See values-*.yaml files

## Troubleshooting
...
EOF
```

### 6. CI/CD Integration

```yaml
# .github/workflows/test-pattern.yml
name: Test Pattern

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install Ansible
        run: pip install ansible ansible-navigator

      - name: Run syntax check
        run: ansible-playbook deploy.yml --syntax-check

      - name: Run validation
        run: ansible-playbook deploy.yml --check
```

---

## Next Steps

1. **Read the [End-User Guide](END-USER-GUIDE.md)** - Learn about the simplified VP Operator workflow
2. **Explore Examples** - Check `quarkus-reference-app/` for a complete example
3. **Run Tests** - Execute tests in `tests/` directory
4. **Join Community** - Contribute to Validated Patterns

---

## Additional Resources

- **Validated Patterns Documentation:** https://validatedpatterns.io
- **OpenShift GitOps:** https://docs.openshift.com/gitops/
- **Ansible Documentation:** https://docs.ansible.com
- **Helm Documentation:** https://helm.sh/docs/

---

**Document Version:** 1.0
**Last Updated:** 2025-10-27
**Maintained By:** Validated Patterns Toolkit Development Team
