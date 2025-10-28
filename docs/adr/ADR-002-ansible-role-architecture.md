# ADR-002: Ansible Role Architecture for Validated Patterns Deployment

**Status:** Proposed
**Date:** 2025-01-24
**Decision Makers:** Development Team, Ansible SMEs
**Consulted:** Operations Teams
**Informed:** End Users

## Context and Problem Statement

We need to design idempotent Ansible roles that can deploy Validated Patterns reliably across different OpenShift environments. The roles must:

1. Support multiple Validated Patterns (multicloud-gitops, industrial-edge, medical-diagnosis, etc.)
2. Handle both fresh installations and updates
3. Integrate with the validatedpatterns/common repository
4. Provide comprehensive error handling and rollback capabilities
5. Support execution from both root directory and subdirectory contexts
6. Validate deployments at multiple stages

## Decision Drivers

* **Idempotency**: Multiple runs should produce the same result
* **Modularity**: Roles should be reusable and composable
* **Error Handling**: Graceful failure with clear error messages
* **Flexibility**: Support different patterns and configurations
* **Testability**: Easy to test in isolation
* **Integration**: Work seamlessly with validatedpatterns/common

## Considered Options

### Option 1: Monolithic Playbook
- Single large playbook with all logic
- **Rejected**: Not maintainable, not reusable

### Option 2: Role-Based Architecture with Pattern-Specific Roles
- Separate role for each pattern
- **Rejected**: Too much duplication

### Option 3: Modular Role Architecture with Common Base (Selected)
- Base roles for common functionality
- Pattern-specific variables and templates
- **Selected**: Best balance of reusability and flexibility

## Decision Outcome

**Chosen option:** Option 3 - Modular Role Architecture with Common Base

### External Dependencies

**Important Update (2025-01-24):** The validatedpatterns/common repository has evolved to use a **multisource architecture** with external Helm chart repositories and a separate Ansible collection.

#### Ansible Collections

Required collections (in `files/requirements.yml`):

```yaml
collections:
  - name: rhvp.cluster_utils
    version: ">=1.0.0"
    description: "Validated Patterns cluster utilities and secret management"
  - name: kubernetes.core
    version: ">=2.4.0"
  - name: community.general
    version: ">=5.0.0"
  - name: ansible.posix
    version: ">=1.5.0"
```

#### Helm Chart Repositories

All Helm charts are now in separate repositories (multisource architecture):

| Chart | Repository | Version | Purpose |
|-------|------------|---------|---------|
| **clustergroup-chart** | validatedpatterns/clustergroup-chart | 0.9.* | Core pattern orchestration |
| **pattern-install-chart** | validatedpatterns/pattern-install-chart | Latest | Pattern installation |
| **hashicorp-vault-chart** | validatedpatterns/hashicorp-vault-chart | Latest | Vault integration |
| **golang-external-secrets-chart** | validatedpatterns/golang-external-secrets-chart | Latest | External Secrets Operator |
| **acm-chart** | validatedpatterns/acm-chart | Latest | Advanced Cluster Management |
| **letsencrypt-chart** | validatedpatterns/letsencrypt-chart | Latest | Let's Encrypt integration |

#### Git Integration

The common repository is integrated as a **git subtree** (not submodule):

```bash
# Initial import
scripts/make-common-subtree.sh

# Update existing subtree
git remote add -f common-upstream https://github.com/validatedpatterns/common.git
git merge -s subtree -Xtheirs -Xsubtree=common common-upstream/main
```

#### Multisource Configuration

Required in `values-global.yaml`:

```yaml
main:
  multiSourceConfig:
    enabled: true
    clusterGroupChartVersion: 0.9.*
```

### Role Structure

```
ansible/
├── roles/
│   ├── validated_patterns_prerequisites/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── check_cluster.yml
│   │   │   ├── check_operators.yml
│   │   │   └── install_prerequisites.yml
│   │   ├── defaults/
│   │   │   └── main.yml
│   │   ├── vars/
│   │   └── README.md
│   │
│   ├── validated_patterns_common/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── setup_common_subtree.yml
│   │   │   ├── update_common_subtree.yml
│   │   │   └── verify_common_version.yml
│   │   ├── defaults/
│   │   └── README.md
│   │
│   ├── validated_patterns_deploy/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── prepare_values_files.yml
│   │   │   ├── deploy_pattern.yml
│   │   │   ├── wait_for_operators.yml
│   │   │   └── verify_deployment.yml
│   │   ├── templates/
│   │   │   ├── values-global.yaml.j2
│   │   │   ├── values-hub.yaml.j2
│   │   │   └── values-secret.yaml.j2
│   │   ├── defaults/
│   │   ├── vars/
│   │   └── README.md
│   │
│   ├── validated_patterns_validate/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── validate_gitops_sync.yml
│   │   │   ├── validate_operators.yml
│   │   │   ├── validate_applications.yml
│   │   │   └── generate_report.yml
│   │   ├── defaults/
│   │   └── README.md
│   │
│   ├── validated_patterns_secrets/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── setup_vault.yml
│   │   │   ├── configure_external_secrets.yml
│   │   │   └── validate_secrets.yml
│   │   ├── templates/
│   │   └── README.md
│   │
│   └── validated_patterns_gitea/
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── deploy_gitea.yml
│       │   ├── configure_gitea.yml
│       │   └── setup_repositories.yml
│       ├── templates/
│       │   ├── gitea-deployment.yaml.j2
│       │   └── gitea-config.yaml.j2
│       └── README.md
│
├── playbooks/
│   ├── deploy_pattern.yml
│   ├── validate_pattern.yml
│   ├── update_pattern.yml
│   ├── setup_gitea.yml
│   └── rollback_pattern.yml
│
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── patterns.yml
│   └── hosts.yml
│
└── ansible.cfg
```

### Key Design Principles

#### 1. Idempotency

All tasks must be idempotent using:
- `k8s` module with `state: present`
- Conditional checks before modifications
- `changed_when` clauses for accurate reporting

```yaml
- name: Deploy OpenShift GitOps Operator
  k8s:
    state: present
    definition:
      apiVersion: operators.coreos.com/v1alpha1
      kind: Subscription
      metadata:
        name: openshift-gitops-operator
        namespace: openshift-operators
      spec:
        channel: stable
        name: openshift-gitops-operator
        source: redhat-operators
        sourceNamespace: openshift-marketplace
  register: gitops_operator

- name: Wait for OpenShift GitOps Operator to be ready
  k8s_info:
    api_version: operators.coreos.com/v1alpha1
    kind: ClusterServiceVersion
    namespace: openshift-operators
  register: csv_list
  until: >
    csv_list.resources |
    selectattr('metadata.name', 'match', '^openshift-gitops-operator.*') |
    selectattr('status.phase', 'equalto', 'Succeeded') |
    list | length > 0
  retries: 30
  delay: 10
```

#### 2. Error Handling

```yaml
- name: Deploy pattern with error handling
  block:
    - name: Apply pattern configuration
      include_tasks: deploy_pattern.yml

  rescue:
    - name: Log deployment failure
      debug:
        msg: "Pattern deployment failed: {{ ansible_failed_result }}"

    - name: Collect diagnostic information
      include_tasks: collect_diagnostics.yml

    - name: Attempt rollback
      include_tasks: rollback_deployment.yml
      when: validated_patterns_auto_rollback | bool

  always:
    - name: Generate deployment report
      include_tasks: generate_report.yml
```

#### 3. Validated Patterns Common Role

The `validated_patterns_common` role handles integration with the validatedpatterns/common repository using the new multisource architecture:

```yaml
# tasks/main.yml for validated_patterns_common role
---
- name: Install rhvp.cluster_utils collection
  ansible.builtin.command:
    cmd: ansible-galaxy collection install rhvp.cluster_utils
  changed_when: false

- name: Setup common repository as git subtree
  include_tasks: setup_common_subtree.yml
  when: not common_subtree_exists | bool

- name: Update common subtree
  include_tasks: update_common_subtree.yml
  when: validated_patterns_update_common | default(false) | bool

- name: Configure Helm repositories
  kubernetes.core.helm_repository:
    name: "{{ item.name }}"
    repo_url: "{{ item.url }}"
    state: present
  loop:
    - name: validatedpatterns
      url: https://charts.validatedpatterns.io
    - name: jetstack
      url: https://charts.jetstack.io
    - name: external-secrets
      url: https://external-secrets.github.io/external-secrets

- name: Verify clustergroup-chart v0.9.* available
  kubernetes.core.helm_info:
    name: clustergroup
    release_namespace: openshift-gitops
  register: clustergroup_info
  failed_when: clustergroup_info.status.version is not match("0.9.*")

- name: Deploy clustergroup-chart with multisource
  kubernetes.core.helm:
    name: clustergroup
    chart_ref: validatedpatterns/clustergroup-chart
    chart_version: "0.9.*"
    release_namespace: openshift-gitops
    values:
      main:
        multiSourceConfig:
          enabled: true
          clusterGroupChartVersion: "0.9.*"
```

#### 4. Pattern Configuration

```yaml
# defaults/main.yml for validated_patterns_deploy role
---
validated_patterns_repo: "https://github.com/validatedpatterns"
validated_patterns_branch: "main"
validated_patterns_name: "multicloud-gitops"
validated_patterns_dir: "{{ ansible_env.HOME }}/validated-patterns"
validated_patterns_common_version: "0.9.*"
validated_patterns_update_common: false

# Pattern-specific configurations
validated_patterns_config:
  multicloud_gitops:
    repo: "{{ validated_patterns_repo }}/multicloud-gitops"
    values_files:
      - values-global.yaml
      - values-hub.yaml
    required_operators:
      - openshift-gitops-operator
      - advanced-cluster-management
      - external-secrets-operator

  industrial_edge:
    repo: "{{ validated_patterns_repo }}/industrial-edge"
    values_files:
      - values-global.yaml
      - values-datacenter.yaml
      - values-factory.yaml
    required_operators:
      - openshift-gitops-operator
      - advanced-cluster-management
      - amq-streams
      - serverless-operator

  medical_diagnosis:
    repo: "{{ validated_patterns_repo }}/medical-diagnosis"
    values_files:
      - values-global.yaml
      - values-hub.yaml
    required_operators:
      - openshift-gitops-operator
      - odf-operator
      - serverless-operator
      - amq-streams

# Validation settings
validated_patterns_validation:
  enabled: true
  timeout: 1800  # 30 minutes
  retry_count: 3
  retry_delay: 60

# Subdirectory execution support
validated_patterns_execution_context: "{{ lookup('env', 'PATTERN_EXECUTION_CONTEXT') | default('root', true) }}"
validated_patterns_subdirectory: "{{ lookup('env', 'PATTERN_SUBDIRECTORY') | default('', true) }}"
```

### Main Playbook Example

```yaml
# playbooks/deploy_pattern.yml
---
- name: Deploy Validated Pattern
  hosts: localhost
  connection: local
  gather_facts: true

  vars_prompt:
    - name: pattern_name
      prompt: "Which pattern do you want to deploy?"
      default: "multicloud-gitops"
      private: false

    - name: cluster_domain
      prompt: "What is your OpenShift cluster domain?"
      private: false

  pre_tasks:
    - name: Verify OpenShift cluster access
      k8s_info:
        api_version: v1
        kind: Namespace
        name: default
      register: cluster_access
      failed_when: cluster_access.failed

    - name: Display deployment information
      debug:
        msg:
          - "Deploying pattern: {{ pattern_name }}"
          - "Cluster domain: {{ cluster_domain }}"
          - "Execution context: {{ validated_patterns_execution_context }}"

  roles:
    - role: validated_patterns_prerequisites
      tags: ['prerequisites']

    - role: validated_patterns_common
      tags: ['common']

    - role: validated_patterns_secrets
      tags: ['secrets']
      when: validated_patterns_use_vault | default(true) | bool

    - role: validated_patterns_deploy
      tags: ['deploy']
      vars:
        pattern_name: "{{ pattern_name }}"
        cluster_domain: "{{ cluster_domain }}"

    - role: validated_patterns_validate
      tags: ['validate']
      when: validated_patterns_validation.enabled | bool

  post_tasks:
    - name: Display deployment summary
      debug:
        msg:
          - "Pattern deployment completed successfully!"
          - "ArgoCD URL: https://openshift-gitops-server-openshift-gitops.apps.{{ cluster_domain }}"
          - "Pattern repository: {{ validated_patterns_config[pattern_name].repo }}"
```

## Consequences

### Positive

* **Reusability**: Roles can be used across different patterns
* **Maintainability**: Clear separation of concerns
* **Testability**: Each role can be tested independently
* **Flexibility**: Easy to add new patterns
* **Error Recovery**: Comprehensive error handling and rollback

### Negative

* **Complexity**: More files and structure to understand
* **Learning Curve**: Users need to understand Ansible role structure

### Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Role dependencies become complex | Clear documentation, dependency diagrams |
| Version conflicts with common | Pin versions, automated testing |
| Execution context confusion | Environment variables, clear documentation |

## Validation Strategy

1. **Unit Tests**: Test individual tasks with molecule
2. **Integration Tests**: Test complete role execution
3. **End-to-End Tests**: Deploy actual patterns on test clusters
4. **Idempotency Tests**: Run roles multiple times, verify no changes

## References

* [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
* [Ansible Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
* [Kubernetes Ansible Module](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/k8s_module.html)
* [validatedpatterns/common](https://github.com/validatedpatterns/common)

## Next Steps

1. Implement `validated_patterns_prerequisites` role
2. Implement `validated_patterns_common` role
3. Implement `validated_patterns_deploy` role
4. Create comprehensive role documentation
5. Develop molecule tests for each role
