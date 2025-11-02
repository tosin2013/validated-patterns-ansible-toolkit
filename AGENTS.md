# Repository Guidelines

## Project Structure & Module Organization
- Root: `Makefile`, `execution-environment.yml`, `ansible-navigator.yml`.
- Dependencies: `files/requirements.yml` (collections), `files/requirements.txt` (Python), `files/bindep.txt` (system pkgs), plus sample `files/playbook.yml`.
- Docs: `docs/` (Diátaxis style: tutorials/how-to/reference/explanation) with `mkdocs.yml`.
- CI: `.github/workflows/yamllint.yml` for YAML linting.
- **Ansible Roles**: `ansible/roles/` contains 7+ production-ready roles with modular task structure.
- **Common Subtree**: `common/` is imported from [validatedpatterns/common.git](https://github.com/validatedpatterns/common.git) and must be kept in sync.

## Build, Test, and Development Commands
- `make clean` — remove build artifacts and prune images.
- `make token` — verify `ANSIBLE_HUB_TOKEN` and pre-fetch collections.
- `make build` — build the EE image via `ansible-builder`.
- `make test` — run `files/playbook.yml` with `ansible-navigator` against the built image.
- `make inspect` — container metadata; `make info` — layers, versions, packages.
- `make publish` — push image to `TARGET_HUB`; `make shell` — open a shell in the image.
- `make deploy-pattern PATTERN_NAME=<name>` — deploy a pattern using ansible-navigator.
- `make validate-pattern PATTERN_NAME=<name>` — validate a deployed pattern.
Environment: export `ANSIBLE_HUB_TOKEN`. Optional overrides: `TARGET_NAME`, `TARGET_TAG`, `CONTAINER_ENGINE` (podman), `TARGET_HUB`.
Example: `CONTAINER_ENGINE=podman TARGET_TAG=v5 make build test`.

### Common Makefile Commands (from common/Makefile)
- `make -f common/Makefile operator-deploy` — deploy pattern via Validated Patterns Operator.
- `make -f common/Makefile validate-prereq` — verify cluster prerequisites.
- `make -f common/Makefile validate-origin` — verify git repository accessibility.
- `make -f common/Makefile load-secrets` — load secrets into configured backend.
- `make -f common/Makefile argo-healthcheck` — check all ArgoCD applications are synced.
- `make -f common/Makefile uninstall` — uninstall pattern and clean up resources.

## End-to-End Deployment Workflow

### Quick Start for Users
The recommended workflow for deploying patterns end-to-end:

```bash
# 1. Build and test the execution environment
make build test

# 2. Validate cluster prerequisites (safe, non-destructive)
make check-prerequisites

# 3. Deploy complete pattern using Ansible roles
make end2end-deployment

# 4. For interactive debugging mode
make end2end-deployment-interactive

# 5. Clean up resources when done
make end2end-cleanup
```

### Key Targets
- **`make check-prerequisites`** — Validate cluster readiness without making changes
- **`make end2end-deployment`** — Deploy complete pattern using all Ansible roles (MAIN ENTRY POINT)
- **`make end2end-deployment-interactive`** — Same deployment in interactive mode for debugging
- **`make end2end-cleanup`** — Remove pattern resources (retains shared infrastructure)
- **`make end2end-help`** — Show complete workflow documentation

### How It Works
- **Orchestration:** Pure Ansible roles (modular, reusable, debuggable)
- **Applications:** Deployed via ArgoCD with Helm charts (GitOps)
- **Playbooks:** 
  - `ansible/playbooks/deploy_complete_pattern.yml` — Main deployment
  - `ansible/playbooks/cleanup_pattern.yml` — Safe cleanup
  - `ansible/playbooks/test_prerequisites.yml` — Prerequisite validation

### Integration with common/Makefile
- **Root Makefile (here):** Development deployment using Ansible roles
- **Common Makefile:** Alternative end-user path using Helm operator
- Both paths available; choose based on control needs (Ansible for dev, Helm for simplicity)

## Coding Style & Naming Conventions
- YAML: 2-space indent, no tabs, lowercase keys with hyphens; files end with `.yml`.
- Keep `execution-environment.yml` minimal; add deps to `files/*` instead of inline.
- Docs: concise Markdown; relative links under `docs/`.
- Make targets: lowercase, verbs (e.g., `build`, `test`).
- Ansible roles: follow standard structure (`tasks/`, `defaults/`, `vars/`, `handlers/`, `meta/`, `README.md`).
- Role tasks: use `include_tasks` for modularity, prefix with action verb (e.g., `check_`, `deploy_`, `validate_`).

## Ansible Roles Architecture

### Available Roles (Reusable Components)
1. **validated_patterns_prerequisites** — Cluster validation (OpenShift version, operators, resources, RBAC, storage, network).
2. **validated_patterns_common** — Helm/GitOps infrastructure (Helm install, ArgoCD, clustergroup chart, collections).
3. **validated_patterns_operator** — Simplified end-user deployment via VP Operator.
4. **validated_patterns_deploy** — Application deployment via ArgoCD and BuildConfigs.
5. **validated_patterns_gitea** — Local git repository for development environments.
6. **validated_patterns_secrets** — Secrets management (sealed secrets, credentials, validation).
7. **validated_patterns_validate** — Comprehensive pre/post-deployment validation and health checks.
8. **validated_patterns_cleanup** — Resource cleanup (Pattern CRs, ArgoCD apps, namespaces).

### Role Task Structure (Modular & Reusable)
Each role uses `include_tasks` to separate concerns:
```yaml
# ansible/roles/validated_patterns_prerequisites/tasks/main.yml
- name: Include OpenShift version check
  include_tasks: check_openshift_version.yml
- name: Include operator check
  include_tasks: check_operators.yml
- name: Include cluster resources check
  include_tasks: check_cluster_resources.yml
```

**Individual task files** (e.g., `check_openshift_version.yml`, `validate_health.yml`) can be reused in:
- Custom playbooks
- End-to-end tests
- Other roles via `include_tasks` with relative/absolute paths

### Role Dependencies & Execution Order
**Recommended sequence for full deployment**:
1. `validated_patterns_prerequisites` — Validate cluster readiness first.
2. `validated_patterns_common` — Install foundation (Helm, ArgoCD, collections).
3. `validated_patterns_gitea` — (Optional) Setup local git for development.
4. `validated_patterns_secrets` — Configure secrets management.
5. `validated_patterns_deploy` — Deploy application patterns.
6. `validated_patterns_validate` — Post-deployment validation and health checks.

**Alternative: End-User Workflow**:
- Use `validated_patterns_operator` alone for simplified deployment (it handles steps 1-5 internally).

### Reusing Role Tasks in E2E Tests
**Do NOT re-invoke entire roles unnecessarily**. Instead, reuse specific task files:

```yaml
# Good: Reuse specific validation task
- name: Validate OpenShift version
  include_tasks: ../../ansible/roles/validated_patterns_prerequisites/tasks/check_openshift_version.yml

# Good: Reuse health check
- name: Check cluster health
  include_tasks: ../../ansible/roles/validated_patterns_validate/tasks/validate_health.yml

# Avoid: Re-running entire role when only one check needed
- include_role:
    name: validated_patterns_prerequisites  # This runs ALL prerequisite checks
```

**Example E2E test structure**:
```yaml
# tests/integration/playbooks/custom_e2e_test.yml
- name: Custom E2E Test
  hosts: localhost
  tasks:
    # Reuse prerequisite checks
    - include_tasks: ../../../ansible/roles/validated_patterns_prerequisites/tasks/check_openshift_version.yml
    - include_tasks: ../../../ansible/roles/validated_patterns_prerequisites/tasks/check_storage.yml

    # Deploy using role
    - include_role:
        name: validated_patterns_operator

    # Reuse validation tasks
    - include_tasks: ../../../ansible/roles/validated_patterns_validate/tasks/validate_health.yml
    - include_tasks: ../../../ansible/roles/validated_patterns_deploy/tasks/verify_deployment.yml
```

## Testing Guidelines

### Linting & Syntax Checks
- Lint: `make lint` (yamllint). CI runs on push/PR.
- Validate builds with `make test`; for fast checks use: `ansible-navigator run files/playbook.yml --syntax-check --mode stdout`.
- Prefer small, reversible changes; test with `podman` locally.

### End-to-End Testing Best Practices
1. **Always clean up before testing**: Run cleanup to ensure fresh state.
2. **Reuse role tasks, not entire roles**: Include specific task files for efficiency.
3. **Test in isolation**: Each e2e test should be independently runnable.
4. **Validate cleanup**: Ensure all resources are removed after test completion.
5. **Document test scenarios**: Clearly explain what each test validates.

### Cleanup Procedures
**CRITICAL**: Always clean up before running e2e tests to avoid conflicts.

**Option 1: Use validated_patterns_cleanup role (RECOMMENDED for E2E tests)**:
```yaml
- name: Pre-test cleanup
  include_role:
    name: validated_patterns_cleanup
  # Default behavior retains shared infrastructure:
  # cleanup_gitops: false   # Keep ArgoCD (from common/ subtree)
  # cleanup_gitea: false    # Keep Gitea (for development)
  # cleanup_operator: false # Keep operator (reusable)
```

**Why retain infrastructure?**
- GitOps/ArgoCD is deployed by `common/` subtree and shared across patterns
- Gitea provides local git repositories for development
- VP Operator can manage multiple pattern deployments
- Faster test iterations without reinstallation

**Option 2: Automated cleanup script**:
```bash
./tests/integration/cleanup/cleanup.sh
```

**Option 3: Ansible cleanup playbook**:
```bash
ansible-playbook tests/integration/cleanup/cleanup_deployment.yml
```

**Option 4: Manual cleanup using oc commands**:
```bash
# Delete Pattern CR (critical!)
oc delete pattern <pattern-name> -n openshift-operators

# Delete ArgoCD applications
oc delete applications --all -n openshift-gitops

# Delete application namespaces
oc delete namespace validated-patterns quarkus-app-dev quarkus-app-prod

# Optional: Remove GitOps
oc delete namespace openshift-gitops

# Optional: Uninstall VP Operator
oc delete subscription patterns-operator -n openshift-operators
oc delete csv -n openshift-operators $(oc get csv -n openshift-operators | grep patterns-operator | awk '{print $1}')
```

**Resources to clean** (comprehensive checklist):
- ✅ Pattern Custom Resources (`oc get pattern -A`) — **ALWAYS**
- ✅ ArgoCD Applications (`oc get applications -n openshift-gitops`) — **ALWAYS**
- ✅ Application namespaces (validated-patterns, quarkus-app-*, etc.) — **ALWAYS**
- ✅ ConfigMaps and Secrets created by patterns — **ALWAYS**
- ✅ BuildConfigs and ImageStreams (if testing builds) — **ALWAYS**
- ✅ Routes and Services (application-specific) — **ALWAYS**
- ⚠️ OpenShift GitOps namespace — **RARELY** (only if common/ subtree requires redeployment)
- ⚠️ Gitea namespace — **RARELY** (only if starting completely fresh)
- ⚠️ Subscriptions and CSVs — **RARELY** (only if testing operator installation itself)

### Validating Cleanup Completeness
```bash
# Verify no Pattern CRs remain
oc get pattern -A

# Verify no ArgoCD apps remain
oc get applications -n openshift-gitops

# Verify namespaces deleted
oc get namespaces | grep -E 'validated-patterns|quarkus-app'

# Check operator status
oc get csv -n openshift-operators | grep patterns-operator
```

## Common Subtree Management (CRITICAL)

The `common/` directory is a **git subtree** imported from [validatedpatterns/common.git](https://github.com/validatedpatterns/common.git).

**⚠️ IMPORTANT**: This repository updates frequently. Keep in sync before major development work.

### Official Update Procedure (from validatedpatterns documentation)

**First-time setup** (only if common/ doesn't exist):
```bash
./common/scripts/make_common_subtree.sh
```

**Update existing common subtree** (recommended method):
```bash
# Option 1: Using utilities script (recommended)
curl -s https://raw.githubusercontent.com/validatedpatterns/utilities/main/scripts/update-common-everywhere.sh | bash

# Option 2: Manual update
git remote add -f common-upstream https://github.com/validatedpatterns/common.git
git merge -s subtree -Xtheirs -Xsubtree=common common-upstream/main
```

**Check common/ version**:
```bash
cd common/
git log --oneline -n 5  # Check recent commits
cd ..
```

**When to update common/**:
- ✅ Before starting new feature development
- ✅ Before running comprehensive e2e tests
- ✅ When pattern deployment fails with unknown errors
- ✅ When upstream releases new features/fixes
- ✅ Monthly or before major releases

**Verify common/ Makefile is accessible**:
```bash
make -f common/Makefile help
```

### Integration with Root Makefile
The root `Makefile` includes pattern deployment targets that complement `common/Makefile`:
- Root Makefile: EE building, testing, docs, pattern deployment via ansible-navigator.
- Common Makefile: Pattern installation, validation, secrets, ArgoCD health checks.

**Example workflow**:
```bash
# Build EE (root Makefile)
make build test

# Deploy pattern (common Makefile)
make -f common/Makefile operator-deploy

# Validate deployment (common Makefile)
make -f common/Makefile validate-prereq argo-healthcheck

# Run e2e tests (root Makefile + ansible-navigator)
ansible-navigator run tests/integration/playbooks/test_end_to_end.yml
```

## Commit & Pull Request Guidelines
- Commits: short, imperative subject; include scope when helpful. Examples: `fix: update bindep openssl-devel`, `docs: clarify publish steps`.
- PRs include: description of change, rationale, sample command(s) used, image tag produced, and `make test` output snippet. Link related issues and update `docs/` when behavior changes.
- **Before PR**: Ensure `common/` is up-to-date, run cleanup, then `make lint build test`.
- **Role changes**: Update role `README.md` and `docs/ANSIBLE-ROLES-REFERENCE.md`.

## Security & Configuration Tips
- Do not commit secrets (e.g., `ANSIBLE_HUB_TOKEN`, kubeconfigs). Use env vars and local config mounts.
- For private mirrors, adjust `ansible.cfg` and pip/yum config via `additional_build_steps` and mounted files.
- Use `podman` as the standard container engine in this repo and CI.
- **Secrets management**: Use validated_patterns_secrets role; supports Vault and Kubernetes backends.

## Secrets Management Guidelines (CRITICAL - MUST IMPLEMENT)

**⚠️ IMPORTANT: Every pattern deployment MUST implement proper secrets management. This is not optional.**

### Overview

Secrets management is critical for:
- 🔐 Database credentials
- 🔑 API keys and tokens  
- 📝 TLS certificates
- 🔓 SSH keys and passphrases
- 🛡️ OAuth and authentication credentials
- 🔑 Third-party service credentials

### Red Hat OpenShift External Secrets Operator (RECOMMENDED)

For production deployments on OpenShift, use the **External Secrets Operator**. This is the industry-standard approach recommended by Red Hat.

📖 **[Red Hat Official Documentation: External Secrets Operator for Red Hat OpenShift](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift)**

**Key features**:
- ✅ Centralized secrets management (AWS Secrets Manager, HashiCorp Vault, Azure Key Vault, etc.)
- ✅ Automatic secret synchronization and rotation
- ✅ GitOps-friendly (SecretStore and ClusterSecretStore CRDs)
- ✅ Fine-grained access control and RBAC
- ✅ Audit logging for compliance (PCI-DSS, HIPAA, SOC2)
- ✅ Red Hat-supported and maintained

### Toolkit Secrets Implementation

The `validated_patterns_secrets` role provides:

```bash
# Location: ansible/roles/validated_patterns_secrets/

# Capabilities:
# ✓ External Secrets Operator setup and configuration
# ✓ SecretStore creation for your backend (Vault, AWS, Azure, etc.)
# ✓ Secret generation and validation
# ✓ Secret rotation policies
# ✓ RBAC and access control
# ✓ Compliance verification
```

### Secrets Backends Supported

1. **External Secrets Operator + AWS Secrets Manager** (PRODUCTION RECOMMENDED)
   - Centralized secret storage in AWS
   - Automatic rotation support
   - Enterprise-grade security
   - See: [ESO AWS SecretStore](https://external-secrets.io/latest/provider/aws-secrets-manager/)

2. **External Secrets Operator + HashiCorp Vault** (ENTERPRISE RECOMMENDED)
   - Complete secrets management platform
   - Policy-based access control
   - Audit logging and compliance
   - Multi-backend support
   - See: [ESO Vault Documentation](https://external-secrets.io/latest/provider/hashicorp-vault/)

3. **External Secrets Operator + Azure Key Vault** (AZURE CLOUD)
   - Native Azure integration
   - Managed service
   - Role-based access control
   - See: [ESO Azure Documentation](https://external-secrets.io/latest/provider/azure-key-vault/)

4. **Sealed Secrets** (GitOps-FRIENDLY, DEVELOPMENT)
   - Secrets encrypted at rest in git
   - Version-controlled secrets
   - Good for development and testing
   - NOT recommended for production sensitive data

5. **Kubernetes Secrets** (DEVELOPMENT ONLY - NOT PRODUCTION)
   - Built-in Kubernetes secrets
   - Quick setup for testing
   - Secrets stored as base64 (NOT encrypted)
   - ❌ **NEVER use for production credentials**

### Implementation Steps

#### Step 1: Choose Your Backend
```bash
# Determine your secrets backend:
# - AWS Secrets Manager (if using AWS)
# - HashiCorp Vault (enterprise choice)
# - Azure Key Vault (if using Azure)
# - GCP Secret Manager (if using GCP)
# - Sealed Secrets (for GitOps-friendly development)
```

#### Step 2: Configure the Secrets Role
```bash
# Edit your pattern's deployment playbook
# to include the validated_patterns_secrets role with appropriate backend:

- name: Configure Secrets Backend
  include_role:
    name: validated_patterns_secrets
  vars:
    # Example: Using Vault backend
    secrets_backend: vault
    vault_addr: "https://vault.example.com"
    vault_token: "{{ vault_credentials }}"
    vault_path: "secret/data/my-pattern"
```

#### Step 3: Create SecretStore
```yaml
# Example SecretStore for Vault
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-secretstore
  namespace: my-pattern
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret/data"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "my-pattern-sa"
```

#### Step 4: Define External Secrets
```yaml
# Example ExternalSecret
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-credentials
  namespace: my-pattern
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-secretstore
    kind: SecretStore
  target:
    name: app-credentials
    creationPolicy: Owner
  data:
    - secretKey: db-password
      remoteRef:
        key: database
        property: password
    - secretKey: api-key
      remoteRef:
        key: api
        property: key
```

#### Step 5: Use Secrets in Deployments
```yaml
# Reference the External Secret in your deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-credentials
              key: db-password
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: app-credentials
              key: api-key
```

### Deployment Checklist

Before deploying any pattern, verify:

- ✅ **Backend selected** (AWS, Vault, Azure, GCP, or Sealed Secrets)
- ✅ **Backend credentials configured** in cluster or via OIDC
- ✅ **validated_patterns_secrets role** included in playbook
- ✅ **SecretStore created** in the pattern namespace
- ✅ **External Secrets defined** for each credential type
- ✅ **Rotations configured** (if backend supports it)
- ✅ **RBAC policies set** (who can read/write secrets)
- ✅ **Audit logging enabled** (for compliance requirements)
- ✅ **Tested with dummy values** (non-sensitive credentials)

### Reference Documentation

- 📖 [Red Hat External Secrets Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift)
- 📖 [External Secrets Operator Project](https://external-secrets.io/)
- 📖 [Toolkit Secrets Role](ansible/roles/validated_patterns_secrets/README.md)
- 📖 [ONBOARDING.md Secrets Section](ONBOARDING.md#part-4-secrets-management-critical---must-have)

### Common Secrets Mistakes (AVOID)

- ❌ **Storing secrets in ConfigMaps** — Use External Secrets Operator instead
- ❌ **Committing secrets to git** — Even encrypted secrets should use proper backend
- ❌ **Using base64-encoded "secrets"** — Base64 is NOT encryption; use real encryption backends
- ❌ **Hardcoding credentials** — Always externalize to backend
- ❌ **Single shared credentials** — Use per-application and per-environment secrets
- ❌ **No rotation** — Implement automatic rotation policies
- ❌ **No audit logging** — Track all secret access for compliance

## Agent-Specific Instructions
- Scope: entire repo. Preserve file layout and target names.
- When adding dependencies, update `files/requirements*.{yml,txt}` and `files/bindep.txt` accordingly.
- **Before opening a PR**: Update `common/` subtree, run cleanup playbook, then `make lint build test`.
- **Role development**: Keep tasks modular (use `include_tasks`), add task-level documentation, update role README.
- **E2E tests**: 
  - **ALWAYS use Ansible roles for deployment and teardown** (validated_patterns_cleanup, validated_patterns_operator, validated_patterns_deploy)
  - Clean up before tests using `validated_patterns_cleanup` role
  - Deploy using `validated_patterns_operator` or `validated_patterns_deploy` role
  - Reuse individual role tasks during validation, not entire roles
  - Clean up after tests using `validated_patterns_cleanup` role
- **Common updates**: Check upstream [validatedpatterns/common.git](https://github.com/validatedpatterns/common.git) weekly; merge changes promptly.

## Common Confusion Points (IMPORTANT for LLMs)

### 1. Pattern Name: This is a REFERENCE/TEMPLATE
- **"validated-patterns-ansible-toolkit"** is the reference pattern name
- Users should customize this to their own pattern name:
  - `values-global.yaml`: Change `global.pattern`
  - `values-hub.yaml`: Update pattern-specific configs
  - Cleanup variables: Update `cleanup_pattern_name`
- This repository is meant to be forked/copied and customized

### 2. Values Files: These are EXAMPLES
- `values-global.yaml` and `values-hub.yaml` contain placeholder values
- Users must customize:
  - Git repository URLs (point to their fork or custom repo)
  - Pattern names
  - Namespace names
  - Application configurations
- These files are used during pattern deployment, NOT during EE build

### 3. Deployment Methods
- **Development Workflow**: Use `ansible/playbooks/deploy_complete_pattern.yml`
  - Executes roles 1-2, 4-7 in sequence
  - Granular control, easier debugging
  - Best for: Pattern development, learning, customization
- **End-User Workflow**: Use `validated_patterns_operator` role directly
  - Simplified deployment via VP Operator
  - Handles all steps internally
  - Best for: Production deployment, existing patterns, simplicity

### 4. Common Subtree (common/) Usage
- **When used**: During pattern deployment (not EE build)
- **What it contains**: Pattern installation chart, deployment scripts, Makefile
- **Common Makefile commands**:
  - `make -f common/Makefile operator-deploy` - Deploy via operator
  - `make -f common/Makefile validate-prereq` - Validate cluster
  - `make -f common/Makefile argo-healthcheck` - Check ArgoCD apps
- **Keep synchronized**: Run `curl -s https://raw.githubusercontent.com/validatedpatterns/utilities/main/scripts/update-common-everywhere.sh | bash`

### 5. Repository Structure vs. User Deployment
- **Root Makefile**: For building/testing EE image (development of this toolkit)
- **Common Makefile**: For deploying patterns (end-user deployment)
- **Ansible roles**: Can be copied to other projects (reusability)
- **Example files**: values-*.yaml, quarkus-reference-app (templates to customize)

## Critical: Role-Based E2E Testing Pattern
When developing or running e2e tests, **ALWAYS use Ansible roles** for consistency:

```yaml
# E2E Test Template
- name: E2E Test with Role-Based Approach
  hosts: localhost
  tasks:
    # 1. Pre-test cleanup using role (default behavior)
    - include_role:
        name: validated_patterns_cleanup
      # Defaults retain shared infrastructure:
      # cleanup_gitops: false   # Keep ArgoCD (from common/ subtree)
      # cleanup_gitea: false    # Keep Gitea (for development)
      # cleanup_operator: false # Keep operator (reusable)

    # 2. Deploy using role
    - include_role:
        name: validated_patterns_operator

    # 3. Validate using specific task files (not entire roles)
    - include_tasks: ../../ansible/roles/validated_patterns_validate/tasks/validate_health.yml

    # 4. Post-test cleanup using role
    - include_role:
        name: validated_patterns_cleanup
```

This ensures:
- ✅ Consistent cleanup across all tests
- ✅ Reusable deployment logic
- ✅ Proper resource management
- ✅ No manual `oc` commands scattered in tests
- ✅ Shared infrastructure retained for efficiency (GitOps, Gitea, Operator)
- ✅ Faster test iterations without reinstallation
