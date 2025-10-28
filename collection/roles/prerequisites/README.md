# Ansible Role: prerequisites

[![License](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](https://github.com/tosin2013/validated-patterns-ansible-toolkit/blob/main/LICENSE)

Validates that an OpenShift cluster meets all prerequisites for deploying Red Hat Validated Patterns.

## Description

This role performs comprehensive prerequisite validation before deploying Validated Patterns. It checks cluster resources, OpenShift version compatibility, required operators, network connectivity, RBAC permissions, and storage configuration.

**Key Features:**
- ✅ OpenShift version validation (4.12+)
- ✅ Cluster resource availability checks
- ✅ Required operators verification
- ✅ Network connectivity testing
- ✅ RBAC permissions validation
- ✅ Storage class verification
- ✅ Comprehensive error reporting
- ✅ Non-destructive checks

## Requirements

- **Ansible**: >= 2.15.0
- **Collections**:
  - `kubernetes.core` >= 2.3.0
- **Python Libraries**:
  - `kubernetes` >= 12.0.0
  - `openshift` >= 0.12.0
- **OpenShift**: 4.12+ or OCP 4.12+
- **Access**: Cluster admin or equivalent permissions
- **Kubeconfig**: Properly configured kubeconfig file

## Role Variables

### Required Variables

None. All variables have sensible defaults.

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `min_openshift_version` | `"4.12"` | Minimum OpenShift version required |
| `min_worker_nodes` | `3` | Minimum number of worker nodes |
| `min_cpu_per_node` | `8` | Minimum vCPUs per worker node |
| `min_memory_per_node` | `16` | Minimum memory (GB) per worker node |
| `min_storage_gb` | `100` | Minimum available storage (GB) |
| `check_only` | `false` | Only check without failing on errors |
| `fail_on_error` | `true` | Fail playbook on validation errors |
| `required_operators` | `["openshift-gitops-operator"]` | List of required operators |
| `required_storage_classes` | `[]` | List of required storage classes |
| `check_network` | `true` | Enable network connectivity checks |
| `check_rbac` | `true` | Enable RBAC permissions checks |
| `kubeconfig_path` | `~/.kube/config` | Path to kubeconfig file |

### Example Variable Configuration

```yaml
# Strict validation
min_openshift_version: "4.14"
min_worker_nodes: 5
min_cpu_per_node: 16
min_memory_per_node: 32
fail_on_error: true

# Required operators
required_operators:
  - openshift-gitops-operator
  - openshift-pipelines-operator
  - sealed-secrets-operator

# Required storage classes
required_storage_classes:
  - gp3-csi
  - ocs-storagecluster-ceph-rbd
```

## Dependencies

- `kubernetes.core` collection

## Example Playbook

### Basic Usage

```yaml
---
- name: Validate cluster prerequisites
  hosts: localhost
  connection: local
  gather_facts: false

  roles:
    - tosin2013.validated_patterns_toolkit.prerequisites
```

### Advanced Usage with Custom Variables

```yaml
---
- name: Validate prerequisites with custom requirements
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    min_openshift_version: "4.14"
    min_worker_nodes: 5
    min_cpu_per_node: 16
    min_memory_per_node: 32
    required_operators:
      - openshift-gitops-operator
      - openshift-pipelines-operator
    check_only: false
    fail_on_error: true

  roles:
    - tosin2013.validated_patterns_toolkit.prerequisites
```

### Check Only Mode (No Failures)

```yaml
---
- name: Check prerequisites without failing
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    check_only: true
    fail_on_error: false

  roles:
    - tosin2013.validated_patterns_toolkit.prerequisites

  post_tasks:
    - name: Display validation results
      ansible.builtin.debug:
        var: prerequisite_check_results
```

## Tasks Performed

This role performs the following validation tasks:

1. **OpenShift Version Check** (`check_openshift_version.yml`)
   - Validates OpenShift version >= minimum required
   - Checks cluster version operator status
   - Verifies upgrade status

2. **Cluster Resources Check** (`check_cluster_resources.yml`)
   - Validates number of worker nodes
   - Checks CPU availability per node
   - Verifies memory availability per node
   - Validates total cluster capacity

3. **Operators Check** (`check_operators.yml`)
   - Verifies required operators are installed
   - Checks operator status and health
   - Validates operator versions

4. **Network Check** (`check_network.yml`)
   - Tests cluster network connectivity
   - Validates DNS resolution
   - Checks external connectivity
   - Verifies service mesh (if applicable)

5. **RBAC Check** (`check_rbac.yml`)
   - Validates cluster admin permissions
   - Checks required ClusterRoles
   - Verifies ServiceAccount permissions
   - Validates RoleBindings

6. **Storage Check** (`check_storage.yml`)
   - Validates storage classes exist
   - Checks available storage capacity
   - Verifies PV provisioning
   - Tests dynamic provisioning

## Return Values

The role sets the following facts:

| Fact | Type | Description |
|------|------|-------------|
| `prerequisite_check_passed` | boolean | Overall validation result |
| `prerequisite_check_results` | dict | Detailed check results |
| `prerequisite_errors` | list | List of validation errors |
| `prerequisite_warnings` | list | List of validation warnings |

### Example Return Values

```yaml
prerequisite_check_passed: true
prerequisite_check_results:
  openshift_version: "4.14.1"
  worker_nodes: 5
  total_cpu: 80
  total_memory: 160
  operators_installed: ["openshift-gitops-operator"]
  storage_classes: ["gp3-csi"]
prerequisite_errors: []
prerequisite_warnings:
  - "Storage capacity below recommended 500GB"
```

## Error Handling

The role provides comprehensive error handling:

- **Validation Errors**: Detailed error messages for each failed check
- **Warnings**: Non-critical issues that don't prevent deployment
- **Check Only Mode**: Run validations without failing the playbook
- **Retry Logic**: Automatic retries for transient failures
- **Detailed Logging**: Comprehensive logging of all checks

## License

GPL-3.0-or-later

## Author

Tosin Akinosho (tosin.akinosho@gmail.com)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](https://github.com/tosin2013/validated-patterns-ansible-toolkit/blob/main/CONTRIBUTING.md).

## Support

- **Issues**: https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues
- **Documentation**: https://github.com/tosin2013/validated-patterns-ansible-toolkit/tree/main/docs
