# Ansible Roles Reference - Validated Patterns Toolkit

**Version:** 1.0
**Last Updated:** 2025-10-27

---

## Table of Contents

1. [Overview](#overview)
2. [Role Summary](#role-summary)
3. [Development Roles (6 Roles)](#development-roles-6-roles)
4. [End-User Role (1 Role)](#end-user-role-1-role)
5. [Role Execution Order](#role-execution-order)
6. [Quick Reference](#quick-reference)

---

## Overview

The Validated Patterns Toolkit provides 7 Ansible roles organized into two workflows:

- **Development Workflow:** 6 roles for pattern developers (full control)
- **End-User Workflow:** 1 role for pattern consumers (simplified)

### Role Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Ansible Roles                             │
└─────────────────────────────────────────────────────────────┘

Development Workflow (6 Roles):
  1. validated_patterns_prerequisites  → Validate cluster
  2. validated_patterns_common         → Deploy infrastructure
  4. validated_patterns_deploy         → Deploy pattern
  5. validated_patterns_gitea          → Local development
  6. validated_patterns_secrets        → Manage secrets
  7. validated_patterns_validate       → Validate deployment

End-User Workflow (1 Role):
  3. validated_patterns_operator       → VP Operator (all-in-one)

Utility Role:
  8. validated_patterns_cleanup        → Clean up resources
```

---

## Role Summary

| # | Role Name | Purpose | Workflow | Complexity |
|---|-----------|---------|----------|------------|
| 1 | validated_patterns_prerequisites | Validate cluster readiness | Development | Low |
| 2 | validated_patterns_common | Deploy common infrastructure | Development | Medium |
| 3 | validated_patterns_operator | VP Operator deployment | End-User | Low |
| 4 | validated_patterns_deploy | Deploy pattern applications | Development | Medium |
| 5 | validated_patterns_gitea | Local development environment | Development | Low |
| 6 | validated_patterns_secrets | Secrets management | Development | Medium |
| 7 | validated_patterns_validate | Deployment validation | Development | Low |
| 8 | validated_patterns_cleanup | Resource cleanup | Both | Low |

---

## Development Roles (6 Roles)

### Role 1: validated_patterns_prerequisites

**Purpose:** Validate cluster is ready for pattern deployment

**Key Tasks:**
- Check OpenShift version (4.12+)
- Verify cluster resources (nodes, CPU, memory)
- Check required operators (OpenShift GitOps)
- Test network connectivity
- Validate RBAC permissions
- Verify storage configuration

**Key Variables:**
```yaml
validated_patterns_min_openshift_version: "4.12"
validated_patterns_min_nodes: 3
validated_patterns_min_cpu: 8
validated_patterns_min_memory: 16
validated_patterns_required_operators:
  - openshift-gitops-operator
```

**Usage:**
```yaml
- hosts: localhost
  roles:
    - validated_patterns_prerequisites
```

**Documentation:** [ansible/roles/validated_patterns_prerequisites/docs/DETAILED.md](../ansible/roles/validated_patterns_prerequisites/docs/DETAILED.md)

---

### Role 2: validated_patterns_common

**Purpose:** Deploy common infrastructure (Helm, ArgoCD, clustergroup-chart)

**Key Tasks:**
- Install rhvp.cluster_utils collection
- Configure Helm repositories
- Deploy clustergroup-chart v0.9.*
- Enable multisource architecture
- Configure ArgoCD integration

**Key Variables:**
```yaml
validated_patterns_rhvp_collection_version: "1.0.0"
validated_patterns_clustergroup_chart_version: "0.9.*"
validated_patterns_pattern_name: "common"
validated_patterns_target_revision: "main"
validated_patterns_multisource_enabled: true
validated_patterns_gitops_namespace: "openshift-gitops"
```

**Usage:**
```yaml
- hosts: localhost
  vars:
    validated_patterns_pattern_name: "my-pattern"
  roles:
    - validated_patterns_common
```

**Documentation:** [ansible/roles/validated_patterns_common/docs/DETAILED.md](../ansible/roles/validated_patterns_common/docs/DETAILED.md)

---

### Role 4: validated_patterns_deploy

**Purpose:** Deploy pattern applications via ArgoCD

**Key Tasks:**
- Create pattern namespace
- Deploy ArgoCD Application CR
- Configure GitOps sync policy
- Monitor application sync status
- Verify application health

**Key Variables:**
```yaml
validated_patterns_pattern_name: "my-pattern"
validated_patterns_repo_url: "https://github.com/org/pattern.git"
validated_patterns_target_revision: "main"
validated_patterns_pattern_path: "k8s/overlays/prod"
validated_patterns_sync_policy: "Automatic"
validated_patterns_auto_prune: true
validated_patterns_self_heal: true
```

**Usage:**
```yaml
- hosts: localhost
  vars:
    validated_patterns_pattern_name: "quarkus-reference-app"
    validated_patterns_repo_url: "https://github.com/tosin2013/validated-patterns-ansible-toolkit.git"
    validated_patterns_pattern_path: "quarkus-reference-app/k8s/overlays/prod"
  roles:
    - validated_patterns_deploy
```

**Documentation:** [ansible/roles/validated_patterns_deploy/README.md](../ansible/roles/validated_patterns_deploy/README.md)

---

### Role 5: validated_patterns_gitea

**Purpose:** Deploy Gitea for local pattern development

**Key Tasks:**
- Create gitea namespace
- Deploy Gitea instance
- Configure Gitea repositories
- Set up webhooks
- Create development users

**Key Variables:**
```yaml
validated_patterns_gitea_namespace: "gitea"
validated_patterns_gitea_admin_user: "admin"
validated_patterns_gitea_admin_password: "changeme"
validated_patterns_gitea_create_repos: true
validated_patterns_gitea_repos:
  - name: "my-pattern"
    description: "Pattern repository"
```

**Usage:**
```yaml
- hosts: localhost
  vars:
    validated_patterns_gitea_namespace: "gitea"
    validated_patterns_gitea_admin_password: "{{ lookup('env', 'GITEA_PASSWORD') }}"
  roles:
    - validated_patterns_gitea
```

**Documentation:** [ansible/roles/validated_patterns_gitea/README.md](../ansible/roles/validated_patterns_gitea/README.md)

---

### Role 6: validated_patterns_secrets

**Purpose:** Manage secrets for pattern deployment

**Key Tasks:**
- Create dedicated secrets namespace
- Configure RBAC for secrets access
- Deploy Sealed Secrets operator (optional)
- Create secret templates
- Validate secret encryption

**Key Variables:**
```yaml
validated_patterns_secrets_namespace: "validated-patterns-secrets"
validated_patterns_use_sealed_secrets: true
validated_patterns_secrets:
  - name: "database-credentials"
    namespace: "my-app"
    data:
      username: "admin"
      password: "{{ lookup('env', 'DB_PASSWORD') }}"
```

**Usage:**
```yaml
- hosts: localhost
  vars:
    validated_patterns_secrets_namespace: "validated-patterns-secrets"
    validated_patterns_use_sealed_secrets: true
  roles:
    - validated_patterns_secrets
```

**Documentation:** [ansible/roles/validated_patterns_secrets/README.md](../ansible/roles/validated_patterns_secrets/README.md)

---

### Role 7: validated_patterns_validate

**Purpose:** Validate pattern deployment is successful

**Key Tasks:**
- Check ArgoCD application status
- Verify all pods are running
- Test application endpoints
- Validate secrets are accessible
- Generate validation report

**Key Variables:**
```yaml
validated_patterns_pattern_name: "my-pattern"
validated_patterns_pattern_namespace: "my-app"
validated_patterns_validate_pods: true
validated_patterns_validate_routes: true
validated_patterns_validate_secrets: true
validated_patterns_generate_report: true
```

**Usage:**
```yaml
- hosts: localhost
  vars:
    validated_patterns_pattern_name: "quarkus-reference-app"
    validated_patterns_pattern_namespace: "reference-app"
  roles:
    - validated_patterns_validate
```

**Documentation:** [ansible/roles/validated_patterns_validate/README.md](../ansible/roles/validated_patterns_validate/README.md)

---

## End-User Role (1 Role)

### Role 3: validated_patterns_operator

**Purpose:** Deploy patterns using Validated Patterns Operator (simplified workflow)

**Key Tasks:**
- Install Validated Patterns Operator
- Create Pattern Custom Resource
- Configure GitOps integration
- Monitor operator deployment
- Validate pattern deployment

**Key Variables:**
```yaml
validated_patterns_pattern_name: "my-pattern"
validated_patterns_git_url: "https://github.com/org/pattern.git"
validated_patterns_git_revision: "main"
vp_operator_channel: "stable"
vp_operator_install_plan_approval: "Automatic"
vp_validate_deployment: true
vp_validate_gitops: true
vp_validate_clustergroup: true
```

**Usage:**
```yaml
- hosts: localhost
  vars:
    validated_patterns_pattern_name: "quarkus-reference-app"
    validated_patterns_git_url: "https://github.com/tosin2013/validated-patterns-ansible-toolkit.git"
    validated_patterns_git_revision: "main"
  roles:
    - validated_patterns_operator
```

**Documentation:** [ansible/roles/validated_patterns_operator/README.md](../ansible/roles/validated_patterns_operator/README.md)

**Note:** This role wraps all 6 development roles into a single operator-managed deployment.

---

## Role Execution Order

### Development Workflow Order

```
1. validated_patterns_prerequisites
   ↓ Validates cluster readiness

2. validated_patterns_common
   ↓ Deploys common infrastructure

4. validated_patterns_deploy
   ↓ Deploys pattern applications

5. validated_patterns_gitea (optional)
   ↓ Sets up local development

6. validated_patterns_secrets
   ↓ Manages secrets

7. validated_patterns_validate
   ↓ Validates deployment
```

**Complete Playbook:**
```yaml
---
- name: Deploy pattern with development workflow
  hosts: localhost
  connection: local
  gather_facts: no

  vars:
    validated_patterns_pattern_name: "my-pattern"
    validated_patterns_repo_url: "https://github.com/org/pattern.git"

  roles:
    - validated_patterns_prerequisites
    - validated_patterns_common
    - validated_patterns_deploy
    - validated_patterns_gitea  # Optional
    - validated_patterns_secrets
    - validated_patterns_validate
```

### End-User Workflow Order

```
3. validated_patterns_operator
   ↓ Handles everything (operator-managed)
```

**Complete Playbook:**
```yaml
---
- name: Deploy pattern with end-user workflow
  hosts: localhost
  connection: local
  gather_facts: no

  vars:
    validated_patterns_pattern_name: "my-pattern"
    validated_patterns_git_url: "https://github.com/org/pattern.git"

  roles:
    - validated_patterns_operator
```

---

## Quick Reference

### Role Selection Guide

**Use Development Workflow When:**
- ✅ Developing a new pattern
- ✅ Customizing pattern deployment
- ✅ Debugging pattern issues
- ✅ Testing pattern changes locally
- ✅ Integrating with CI/CD pipelines
- ✅ Learning pattern internals

**Use End-User Workflow When:**
- ✅ Deploying an existing pattern
- ✅ Production deployment without customization
- ✅ Quick pattern evaluation
- ✅ Minimal configuration required
- ✅ Operator-managed lifecycle preferred

### Common Variable Patterns

#### Pattern Identification
```yaml
validated_patterns_pattern_name: "my-pattern"
validated_patterns_repo_url: "https://github.com/org/pattern.git"
validated_patterns_target_revision: "main"
```

#### GitOps Configuration
```yaml
validated_patterns_gitops_namespace: "openshift-gitops"
validated_patterns_argocd_instance_name: "openshift-gitops"
validated_patterns_sync_policy: "Automatic"
validated_patterns_auto_prune: true
validated_patterns_self_heal: true
```

#### Secrets Configuration
```yaml
validated_patterns_secrets_namespace: "validated-patterns-secrets"
validated_patterns_use_sealed_secrets: true
```

### Testing Roles

Test individual roles:

```bash
# Test prerequisites
ansible-playbook ansible/roles/validated_patterns_prerequisites/tests/test.yml

# Test common
ansible-playbook ansible/roles/validated_patterns_common/tests/test.yml

# Test all roles
for role in ansible/roles/validated_patterns_*/tests/test.yml; do
  echo "Testing $role"
  ansible-playbook "$role"
done
```

### Debugging Roles

Enable debug mode:

```yaml
---
- name: Debug role execution
  hosts: localhost
  vars:
    ansible_verbosity: 2
  roles:
    - validated_patterns_prerequisites
```

Run with verbose output:

```bash
ansible-playbook playbook.yml -vv
```

---

## Additional Resources

### Documentation

- **[Developer Guide](DEVELOPER-GUIDE.md)** - Complete development workflow
- **[End-User Guide](END-USER-GUIDE.md)** - Simplified deployment workflow
- **[Documentation Index](GUIDES-INDEX.md)** - All documentation

### Role-Specific Documentation

- **[validated_patterns_prerequisites](../ansible/roles/validated_patterns_prerequisites/docs/DETAILED.md)** - Detailed prerequisites documentation
- **[validated_patterns_common](../ansible/roles/validated_patterns_common/docs/DETAILED.md)** - Detailed common infrastructure documentation
- **[validated_patterns_deploy](../ansible/roles/validated_patterns_deploy/README.md)** - Pattern deployment documentation
- **[validated_patterns_gitea](../ansible/roles/validated_patterns_gitea/README.md)** - Gitea setup documentation
- **[validated_patterns_secrets](../ansible/roles/validated_patterns_secrets/README.md)** - Secrets management documentation
- **[validated_patterns_validate](../ansible/roles/validated_patterns_validate/README.md)** - Validation documentation
- **[validated_patterns_operator](../ansible/roles/validated_patterns_operator/README.md)** - VP Operator documentation

### External Resources

- **Validated Patterns:** https://validatedpatterns.io
- **OpenShift GitOps:** https://docs.openshift.com/gitops/
- **Ansible Documentation:** https://docs.ansible.com
- **Helm Documentation:** https://helm.sh/docs/

---

**Document Version:** 1.0
**Last Updated:** 2025-10-27
**Maintained By:** Validated Patterns Toolkit Development Team
