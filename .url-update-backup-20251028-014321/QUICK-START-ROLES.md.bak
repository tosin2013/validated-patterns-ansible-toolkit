# Quick Start Guide - Ansible Roles

## Overview

Two production-ready Ansible roles for deploying Validated Patterns on OpenShift:

1. **validated_patterns_prerequisites** - Validate cluster readiness
2. **validated_patterns_common** - Deploy validatedpatterns/common

---

## Prerequisites

```bash
# Install required collections
ansible-galaxy collection install -r files/requirements.yml
```

---

## Usage

### Using ansible-navigator (Recommended)

```bash
# Test prerequisites
ansible-navigator run ansible/playbooks/test_prerequisites.yml

# With custom variables
ansible-navigator run ansible/playbooks/test_prerequisites.yml \
  -e validated_patterns_min_nodes=5 \
  -e validated_patterns_min_cpu=16
```

### Using ansible-playbook

```bash
# Create a playbook
cat > deploy.yml << 'PLAYBOOK'
---
- name: Deploy Validated Patterns
  hosts: localhost
  gather_facts: no
  roles:
    - validated_patterns_prerequisites
    - validated_patterns_common
PLAYBOOK

# Run it
ansible-playbook deploy.yml
```

---

## Role Details

### validated_patterns_prerequisites

**Purpose:** Validate cluster is ready for pattern deployment

**Checks:**
- OpenShift version (4.12+)
- Required operators
- Cluster resources (CPU, memory, nodes)
- Network connectivity
- RBAC permissions
- Storage configuration

### validated_patterns_common

**Purpose:** Deploy validatedpatterns/common

**Tasks:**
1. Install rhvp.cluster_utils collection
2. Configure Helm repositories
3. Deploy clustergroup-chart v0.9.*
4. Enable multisource configuration

---

## Documentation

- `ansible/roles/validated_patterns_prerequisites/README.md`
- `ansible/roles/validated_patterns_common/README.md`
- `docs/WEEK-3-PROGRESS.md`
- `docs/PHASE-2-WEEK-3-COMPLETE.md`
