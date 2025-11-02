# End-to-End Deployment Workflow

## Overview
This document describes the complete end-to-end deployment workflow for the Validated Patterns Toolkit.

## Recommended Workflow

### For Developers & Pattern Consumers

**Step 1: Build Execution Environment**
```bash
make build test
```
Builds the Ansible execution environment image and runs basic validation.

**Step 2: Validate Cluster Prerequisites**
```bash
make check-prerequisites
```
Non-destructive check to ensure cluster meets all requirements:
- OpenShift version (4.12+)
- Required operators
- Cluster resources (CPU, memory, nodes)
- Network connectivity
- RBAC permissions
- Storage configuration

**Step 3: Deploy Complete Pattern**
```bash
make end2end-deployment
```
Executes the complete deployment playbook using Ansible roles:
1. Validates cluster prerequisites
2. Deploys common infrastructure (Helm, ArgoCD)
3. Sets up Gitea (optional)
4. Configures secrets management
5. Deploys pattern applications
6. Runs comprehensive validation

**Step 4: (Optional) Interactive Debugging**
```bash
make end2end-deployment-interactive
```
Same as step 3 but in interactive mode for troubleshooting.

**Step 5: Cleanup When Done**
```bash
make end2end-cleanup
```
Removes pattern resources:
- Pattern Custom Resources
- ArgoCD Applications
- Application namespaces
- Related ConfigMaps & Secrets

Retains shared infrastructure (GitOps, Operator, Gitea) for reuse.

## Architecture

### Orchestration Layer (Ansible Roles)
- **validated_patterns_prerequisites** — Cluster validation
- **validated_patterns_common** — Infrastructure deployment
- **validated_patterns_deploy** — Pattern deployment
- **validated_patterns_gitea** — Local git setup
- **validated_patterns_secrets** — Secrets management
- **validated_patterns_validate** — Health checks
- **validated_patterns_cleanup** — Resource cleanup

### Application Layer (Helm + GitOps)
- Applications deployed via ArgoCD
- ArgoCD syncs Helm charts from Git
- Pattern-specific values in `values-*.yaml`

## Two Makefiles in This Repository

### Root Makefile (this folder)
Used for **development** and **user deployment**:
- EE building and testing
- End-to-end deployment using Ansible roles
- Pattern cleanup
- Recommended targets: `make end2end-deployment`

### Common Makefile (common/Makefile)
Used for **alternative end-user deployment**:
- Pattern validation and installation (Helm)
- Simplified operator-based deployment
- Secrets management
- Alternative target: `make -f common/Makefile operator-deploy`

**Recommendation:** Use root Makefile for development (Ansible roles offer more control). Use common/Makefile for simplified end-user deployment.

## Troubleshooting

### Prerequisites Check Fails
```bash
make check-prerequisites
```
Review the error messages and verify:
- OpenShift cluster access
- Required operators installed
- Sufficient cluster resources
- Network connectivity

### Deployment Hangs or Fails
```bash
make end2end-deployment-interactive
```
Use interactive mode to step through and debug each role.

### Cleanup Issues
```bash
make end2end-cleanup
```
By default, retains shared infrastructure. To remove everything:
Edit `ansible/playbooks/cleanup_pattern.yml` and set cleanup vars to true.

## Documentation

- **Developer Guide:** [docs/DEVELOPER-GUIDE.md](docs/DEVELOPER-GUIDE.md)
- **End-User Guide:** [docs/END-USER-GUIDE.md](docs/END-USER-GUIDE.md)
- **Architecture:** [docs/ARCHITECTURE-DIAGRAMS.md](docs/ARCHITECTURE-DIAGRAMS.md)
- **Decision Flowchart:** [docs/DEPLOYMENT-DECISION-FLOWCHART.md](docs/DEPLOYMENT-DECISION-FLOWCHART.md)
- **Ansible Roles Reference:** [docs/ANSIBLE-ROLES-REFERENCE.md](docs/ANSIBLE-ROLES-REFERENCE.md)

## Related Files

- Main deployment playbook: `ansible/playbooks/deploy_complete_pattern.yml`
- Cleanup playbook: `ansible/playbooks/cleanup_pattern.yml`
- Prerequisites check: `ansible/playbooks/test_prerequisites.yml`
- Makefile: `Makefile` (root)
- Common Makefile: `common/Makefile`
