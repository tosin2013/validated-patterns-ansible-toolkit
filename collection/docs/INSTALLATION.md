# Installation Guide

This guide provides detailed instructions for installing the `tosin2013.validated_patterns_toolkit` Ansible collection.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Version Pinning](#version-pinning)
- [Dependency Management](#dependency-management)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

- **Ansible Core**: >= 2.15.0
- **Python**: >= 3.9
- **Operating System**: Linux, macOS, or WSL2 on Windows

### Python Dependencies

Install required Python packages:

```bash
pip install kubernetes>=12.0.0 openshift>=0.12.0 PyYAML>=5.4.1
```

Or use a requirements file:

```bash
# requirements.txt
kubernetes>=12.0.0
openshift>=0.12.0
PyYAML>=5.4.1
jmespath>=0.10.0
```

```bash
pip install -r requirements.txt
```

### OpenShift Cluster Access

Ensure you have:
- Valid kubeconfig file (`~/.kube/config`)
- Cluster admin or equivalent permissions
- OpenShift 4.12+ cluster

Verify access:

```bash
oc whoami
oc version
```

## Installation Methods

### Method 1: Install from Ansible Galaxy (Recommended)

Install the latest version:

```bash
ansible-galaxy collection install tosin2013.validated_patterns_toolkit
```

Install a specific version:

```bash
ansible-galaxy collection install tosin2013.validated_patterns_toolkit:1.0.0
```

Install with force (overwrite existing):

```bash
ansible-galaxy collection install tosin2013.validated_patterns_toolkit --force
```

### Method 2: Install from requirements.yml

Create a `requirements.yml` file:

```yaml
---
collections:
  # Validated Patterns Toolkit
  - name: tosin2013.validated_patterns_toolkit
    version: ">=1.0.0"
  
  # Required dependencies
  - name: kubernetes.core
    version: ">=2.3.0"
  
  - name: community.general
    version: ">=5.0.0"
```

Install all collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

### Method 3: Install from GitHub

Install from the main branch:

```bash
ansible-galaxy collection install git+https://github.com/tosin2013/validated-patterns-ansible-toolkit.git,main
```

Install from a specific branch or tag:

```bash
ansible-galaxy collection install git+https://github.com/tosin2013/validated-patterns-ansible-toolkit.git,v1.0.0
```

### Method 4: Install from Local Source

Clone the repository:

```bash
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit
```

Build the collection:

```bash
ansible-galaxy collection build collection/
```

Install the built collection:

```bash
ansible-galaxy collection install tosin2013-validated_patterns_toolkit-1.0.0.tar.gz
```

## Version Pinning

### Pin to Exact Version

```yaml
# requirements.yml
collections:
  - name: tosin2013.validated_patterns_toolkit
    version: "1.0.0"  # Exact version
```

### Pin to Version Range

```yaml
# requirements.yml
collections:
  - name: tosin2013.validated_patterns_toolkit
    version: ">=1.0.0,<2.0.0"  # Major version 1.x
```

### Pin to Minimum Version

```yaml
# requirements.yml
collections:
  - name: tosin2013.validated_patterns_toolkit
    version: ">=1.0.0"  # 1.0.0 or higher
```

## Dependency Management

### Complete requirements.yml Example

```yaml
---
collections:
  # Validated Patterns Toolkit
  - name: tosin2013.validated_patterns_toolkit
    version: ">=1.0.0,<2.0.0"
    source: https://galaxy.ansible.com
  
  # Kubernetes/OpenShift Management
  - name: kubernetes.core
    version: ">=2.3.0,<3.0.0"
    source: https://galaxy.ansible.com
  
  # General Purpose Modules
  - name: community.general
    version: ">=5.0.0,<6.0.0"
    source: https://galaxy.ansible.com
```

### Install with Upgrade

Upgrade all collections to latest compatible versions:

```bash
ansible-galaxy collection install -r requirements.yml --upgrade
```

### Install to Custom Path

Install to a specific directory:

```bash
ansible-galaxy collection install -r requirements.yml -p ./collections
```

Update `ansible.cfg`:

```ini
[defaults]
collections_paths = ./collections:~/.ansible/collections:/usr/share/ansible/collections
```

## Verification

### Verify Installation

Check installed collections:

```bash
ansible-galaxy collection list
```

Expected output:

```
# /home/user/.ansible/collections/ansible_collections
Collection                                Version
----------------------------------------- -------
tosin2013.validated_patterns_toolkit      1.0.0
kubernetes.core                           2.4.0
community.general                         6.0.0
```

### Verify Collection Content

List roles in the collection:

```bash
ansible-galaxy collection list tosin2013.validated_patterns_toolkit
```

### Test Collection

Create a test playbook:

```yaml
# test_collection.yml
---
- name: Test Validated Patterns Toolkit Collection
  hosts: localhost
  connection: local
  gather_facts: false
  
  tasks:
    - name: Test prerequisites role
      ansible.builtin.include_role:
        name: tosin2013.validated_patterns_toolkit.prerequisites
      vars:
        check_only: true
        fail_on_error: false
```

Run the test:

```bash
ansible-playbook test_collection.yml
```

## Troubleshooting

### Issue: Collection Not Found

**Error**: `ERROR! couldn't resolve module/action 'tosin2013.validated_patterns_toolkit.prerequisites'`

**Solution**:
1. Verify installation: `ansible-galaxy collection list`
2. Check collections path: `ansible-config dump | grep COLLECTIONS_PATHS`
3. Reinstall: `ansible-galaxy collection install tosin2013.validated_patterns_toolkit --force`

### Issue: Version Conflict

**Error**: `ERROR! Cannot meet dependency requirement 'kubernetes.core:>=2.3.0'`

**Solution**:
1. Update dependencies: `ansible-galaxy collection install kubernetes.core --upgrade`
2. Use compatible versions in requirements.yml
3. Check for conflicting requirements

### Issue: Permission Denied

**Error**: `ERROR! - the configured path /usr/share/ansible/collections does not exist`

**Solution**:
1. Install to user directory: `ansible-galaxy collection install tosin2013.validated_patterns_toolkit --force`
2. Or use custom path: `ansible-galaxy collection install -p ./collections tosin2013.validated_patterns_toolkit`

### Issue: Python Dependencies Missing

**Error**: `ModuleNotFoundError: No module named 'kubernetes'`

**Solution**:
```bash
pip install kubernetes openshift PyYAML
```

### Issue: Ansible Version Too Old

**Error**: `ERROR! Ansible version 2.14.0 is too old`

**Solution**:
```bash
pip install --upgrade ansible-core
ansible --version
```

## Upgrade Guide

### Upgrade to Latest Version

```bash
ansible-galaxy collection install tosin2013.validated_patterns_toolkit --upgrade
```

### Upgrade with requirements.yml

Update version in requirements.yml:

```yaml
collections:
  - name: tosin2013.validated_patterns_toolkit
    version: ">=1.1.0"  # New version
```

Install:

```bash
ansible-galaxy collection install -r requirements.yml --upgrade
```

## Uninstallation

Remove the collection:

```bash
ansible-galaxy collection remove tosin2013.validated_patterns_toolkit
```

Or manually remove:

```bash
rm -rf ~/.ansible/collections/ansible_collections/tosin2013/validated_patterns_toolkit
```

## Additional Resources

- **Collection Repository**: https://github.com/tosin2013/validated-patterns-ansible-toolkit
- **Ansible Galaxy**: https://galaxy.ansible.com/tosin2013/validated_patterns_toolkit
- **Documentation**: https://github.com/tosin2013/validated-patterns-ansible-toolkit/tree/main/docs
- **Issues**: https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues

