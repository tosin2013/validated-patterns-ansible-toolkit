# Onboarding Guide: New & Existing Projects

## 🚀 START HERE

### What is This Repository?

The **Validated Patterns Ansible Toolkit** is a reusable reference implementation and toolkit for deploying patterns on OpenShift. It provides:

- ✅ 8 Production-Ready Ansible Roles (reusable, modular)
- ✅ Complete End-to-End Deployment Workflow
- ✅ Gitea Integration for Local Development
- ✅ Pattern Onboarding for New & Existing Projects
- ✅ Development Memory & Workflow Tracking

**Important:** This repository is **never used as standalone**. It is designed to be:
1. **Cloned** to start your pattern project
2. **Integrated** as a git subtree into your pattern repository
3. **Updated** as the toolkit evolves

### Quick Start: Get the Toolkit

#### Step 1: Clone This Repository

```bash
# Clone the Validated Patterns Ansible Toolkit
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git my-pattern
cd my-pattern
```

This creates your project foundation with all toolkit files and examples.

#### Step 2: Choose Your Path

**Option A: New Pattern** (Starting from scratch)
```bash
make onboard-new-project PROJECT_NAME=my-pattern
```

**Option B: Existing Project** (Integrating with existing codebase)
```bash
make onboard-existing-project PROJECT_NAME=my-project
```

**Option C: Use as Reference** (Copy what you need)
- Review the ansible roles in `ansible/roles/`
- Examine example playbooks in `ansible/playbooks/`
- Customize for your use case

#### Step 3: Setup Development Environment

```bash
# Check cluster prerequisites
make check-prerequisites

# Deploy Gitea for local development
make setup-gitea

# Deploy complete pattern
make end2end-deployment
```

#### Step 4: View Documentation

```bash
# Show deployment workflow
make end2end-help

# Show onboarding options
make onboard-help

# View this guide
cat ONBOARDING.md
```

---

### Understanding the Git Subtree Workflow

This repository is meant to be imported into your pattern repository as a **git subtree**. This allows you to:
- ✅ Keep the toolkit separate from your application code
- ✅ Receive toolkit updates from upstream
- ✅ Customize the toolkit for your pattern
- ✅ Maintain clean git history

#### Why Use Subtree?

A git subtree allows:
- Your pattern has complete toolkit (all roles, playbooks, etc.)
- You can update toolkit independently
- Easy to track which version of toolkit your pattern uses
- Clean separation between toolkit and application code

#### Importing the Common Subtree (First Time)

The Validated Patterns toolkit uses a `common/` subtree from [validatedpatterns/common.git](https://github.com/validatedpatterns/common.git). To import it:

**Option 1: Use the Script (Recommended)**

```bash
# First time setup - run the provided script
./common/scripts/make_common_subtree.sh
```

**Option 2: Manual Setup**

```bash
# Add the remote
git remote add -f common-upstream https://github.com/validatedpatterns/common.git

# Merge as subtree
git merge -s subtree -Xtheirs -Xsubtree=common common-upstream/main
```

This imports the common subtree which contains:
- Pattern installation Helm charts
- ArgoCD configuration
- Secrets management
- Validation scripts

#### Updating the Common Subtree

As the toolkit evolves, keep your common subtree in sync:

**Option 1: Use Utilities Script (Recommended)**

```bash
# Downloads and runs the official update script
curl -s https://raw.githubusercontent.com/validatedpatterns/utilities/main/scripts/update-common-everywhere.sh | bash
```

**Option 2: Manual Update**

```bash
# Add remote if not already added
git remote add -f common-upstream https://github.com/validatedpatterns/common.git

# Merge latest changes
git merge -s subtree -Xtheirs -Xsubtree=common common-upstream/main

# Commit the update
git add .
git commit -m "chore: update common subtree"
git push
```

#### When to Update Common Subtree

- ✅ Before starting new feature development
- ✅ Before running comprehensive e2e tests
- ✅ When pattern deployment fails with unknown errors
- ✅ When upstream releases new features/fixes
- ✅ Monthly or before major releases

#### Verifying Common Subtree

```bash
# Check common/ is present
ls -la common/

# Verify Makefile is accessible
make -f common/Makefile help

# Check recent commits in common/
cd common && git log --oneline -n 5 && cd ..
```

---

### Secrets Management

The toolkit supports two different secret formats:

#### Secret Formats Supported

1. **Kubernetes Secrets** - Native K8s secret objects
2. **Sealed Secrets** - Encrypted secrets for GitOps

Both formats are parsed and handled by the Ansible vault role.

#### Using the Vault Role

The `validated_patterns_secrets` role manages all secrets. See documentation:

```bash
# View secrets role
cat ansible/roles/validated_patterns_secrets/README.md

# View example secrets configuration
cat ansible/roles/validated_patterns_secrets/defaults/main.yml
```

#### Secret Configuration

Secrets are typically stored in:
- `files/secrets.yaml` - Secret definitions
- `ansible/roles/validated_patterns_secrets/` - Role configuration

For detailed secret setup, see:
- [Ansible Roles Reference](docs/ANSIBLE-ROLES-REFERENCE.md)
- [Vault Role Documentation](ansible/roles/validated_patterns_secrets/README.md)

---

## Overview

The onboarding process provides:
- **Cluster Detection** — Analyze your cluster to determine requirements
- **Gitea Setup** — Deploy local git repository for development
- **Project Bootstrap** — Initialize new or migrate existing projects
- **Development Workflow** — Develop in Gitea, release to GitHub
- **Development Memory** — Track decisions and project context

## Prerequisites

Before starting:
- Access to OpenShift cluster (4.12+)
- `oc` CLI tool configured
- `git` installed locally
- `make` and `ansible-navigator` available
- (Optional) GitHub account for pushing releases

## Quick Start

```bash
# 1. Detect cluster requirements
make cluster-info

# 2. Validate cluster prerequisites
make check-prerequisites

# 3. Setup development environment (Gitea + pattern)
make onboard-new-project PROJECT_NAME=my-project
# OR for existing project
make onboard-existing-project PROJECT_NAME=my-project

# 4. View onboarding status
make onboard-status PROJECT_NAME=my-project
```

---

## Part 1: Cluster Detection & Analysis

### Understanding Your Cluster

Before deploying a pattern, understand your cluster capabilities:

```bash
# Analyze cluster and display requirements
make cluster-info
```

This command provides:
- OpenShift version and build info
- Available operators and API groups
- Cluster resources (nodes, CPU, memory)
- Storage classes and configuration
- Network policies and egress rules
- RBAC capabilities
- Installed packages and runtime versions

### What This Tells You

The output helps determine:
- ✅ Which roles can be deployed
- ✅ Required operators to install
- ✅ Resource constraints
- ✅ Storage requirements
- ✅ Network/security policies
- ⚠️ Potential deployment limitations

### Example Output

```
========================================
CLUSTER INFORMATION REPORT
========================================

OpenShift Version: 4.14.5
Kubernetes Version: v1.27.6

Available Operators: 45
- Red Hat OpenShift Gitops
- Red Hat OpenStack
- Red Hat OpenShift Pipelines

Cluster Resources:
- Nodes: 3
- Total CPU: 24 cores
- Total Memory: 96 GB
- Available Storage: 500 GB

Network Policy: Enabled
Egress Rules: Restricted

========================================
```

---

## Part 2: New Project Onboarding

### For Brand New Projects

If you're starting a new project from scratch:

```bash
# Step 1: Initialize new project
make onboard-new-project PROJECT_NAME=my-pattern

# This will:
# ✓ Create project directory structure
# ✓ Generate placeholder Helm charts
# ✓ Create sample application files
# ✓ Initialize git repository
# ✓ Deploy Gitea
# ✓ Push to Gitea
# ✓ Create development memory file
```

### What Gets Created

```
my-pattern/
├── ansible/
│   ├── roles/              # Copy of toolkit roles
│   └── playbooks/          # Pattern-specific playbooks
├── helm/
│   └── my-pattern/         # Helm chart for your app
├── k8s/                    # Kubernetes manifests
├── src/                    # Application source code
├── values-global.yaml      # Global configuration
├── values-hub.yaml         # Hub-specific configuration
├── DEVELOPMENT-MEMORY.md   # Development notes & decisions
├── README.md               # Project documentation
└── .gitignore              # Git ignore rules
```

### Development Memory File

The `DEVELOPMENT-MEMORY.md` tracks:

```markdown
# Development Memory: my-pattern

## Project Overview
- Name: my-pattern
- Purpose: [describe the pattern's purpose]
- Owner: [your name]
- Created: [date]

## Architecture Decisions
- [Key decisions made during development]

## Known Limitations
- [Constraints and limitations]

## Development Workflow
- Local development: Gitea (my-pattern-gitea)
- Release to GitHub: github.com/yourorg/my-pattern

## Deployment Requirements
- OpenShift 4.12+
- [Other requirements]

## Notes
- [Ongoing notes and reminders]
```

---

## Part 3: Existing Project Onboarding

### For Projects Already in Use

If you have an existing project:

```bash
# Step 1: Onboard existing project
make onboard-existing-project PROJECT_NAME=my-project

# This will:
# ✓ Create .validated-patterns/ subdirectory in your project
# ✓ Copy all toolkit files to subdirectory (ansible roles, playbooks, etc.)
# ✓ Create DEVELOPMENT-MEMORY.md with onboarding info
# ✓ Generate integration guide showing what to copy
# ✓ Deploy Gitea
# ✓ Push existing code to Gitea
# ✓ Preserve your original git history
```

### Project Structure After Onboarding

```
my-project/                          (Your existing project - UNTOUCHED)
├── src/                             (Your source code)
├── tests/                           (Your tests)
├── pom.xml / package.json / etc.   (Your config)
├── README.md                        (Your documentation)
│
└── .validated-patterns/             (NEW: Toolkit integration directory)
    ├── ansible/
    │   ├── roles/                   (Copy of toolkit roles)
    │   └── playbooks/
    ├── helm/
    │   └── my-project/              (Sample Helm chart)
    ├── values-global.yaml           (Pattern configuration)
    ├── values-hub.yaml
    ├── INTEGRATION-GUIDE.md          (What to copy and where)
    ├── Makefile.patterns            (Pattern-specific Makefile targets)
    └── DEVELOPMENT-MEMORY.md        (Onboarding notes)
```

### Integration Process

Users decide what to copy. Three integration options are available:

```bash
# Option 1: Keep Isolated
# Leave toolkit files in .validated-patterns/
# Simpler management but requires subdirectory references in scripts
# Use this if: You want minimal changes to your project structure

# Option 2: Gradual Integration
# Copy only what you need, when you need it

# Copy Helm chart (if deploying app via ArgoCD)
cp -r .validated-patterns/helm/my-project ./helm/

# Copy playbooks (if automating deployment)
cp -r .validated-patterns/ansible ./automation/

# Copy values files (if using GitOps)
cp .validated-patterns/values-*.yaml ./config/

# Option 3: Full Integration (RECOMMENDED)
# Copy everything to main project directory
# This is the typical pattern when using as a subtree
# Your repository will have complete toolkit and is ready to deploy
cp -r .validated-patterns/* .
rm -rf .validated-patterns/
```

### INTEGRATION-GUIDE.md

The toolkit creates a guide showing:

```markdown
# Integration Guide: my-project

This project has been onboarded to the Validated Patterns toolkit.
All toolkit files are in `.validated-patterns/` - YOUR CODE IS UNTOUCHED.

## Files Available for Integration

### 1. Helm Charts (Optional)
Location: `.validated-patterns/helm/my-project/`
Copy to: `./helm/my-project/`
When: If you want GitOps deployment via ArgoCD
Command: cp -r .validated-patterns/helm/my-project ./helm/

### 2. Ansible Playbooks (Optional)
Location: `.validated-patterns/ansible/`
Copy to: `./ansible/` or `./automation/`
When: If you want automated deployment
Command: cp -r .validated-patterns/ansible ./

### 3. Kubernetes Manifests (Optional)
Location: `.validated-patterns/k8s/`
Copy to: `./k8s/`
When: If you need raw K8s manifests
Command: cp -r .validated-patterns/k8s ./

### 4. Values Configuration (Optional)
Location: `.validated-patterns/values-*.yaml`
Copy to: `./config/` or keep separate
When: Always useful for pattern configuration
Command: cp .validated-patterns/values-*.yaml ./config/

### 5. Development Memory (Recommended)
Location: `.validated-patterns/DEVELOPMENT-MEMORY.md`
Keep in: `.validated-patterns/DEVELOPMENT-MEMORY.md`
When: Always (tracks development decisions)
```

### What Happens to Your Code

- ✅ Your code is **COMPLETELY UNTOUCHED**
- ✅ Your git history is **PRESERVED**
- ✅ Your configuration is **KEPT AS-IS**
- ✅ Toolkit files are **ISOLATED** in `.validated-patterns/`
- ✅ You **CHOOSE WHAT TO COPY** and when
- ✅ Easy to **REVERT** if needed (just delete `.validated-patterns/`)
- ✅ Development memory is **IN SUBDIRECTORY** (not in your main repo)

---

## Part 4: Secrets Management (CRITICAL - Must Have)

### Configuring Secrets for Your Pattern

**⚠️ IMPORTANT: Secrets management is a required component of every pattern deployment.**

The toolkit provides comprehensive secrets management through the `validated_patterns_secrets` role. Secrets are critical for:

- 🔐 Database credentials
- 🔑 API keys and tokens
- 📝 TLS certificates
- 🔓 SSH keys
- 🛡️ Authentication credentials
- 🔑 OAuth tokens and credentials

### Red Hat OpenShift External Secrets Operator

For production deployments on OpenShift, use the **External Secrets Operator**. See the official Red Hat documentation:

📖 **[Red Hat OpenShift External Secrets Operator Documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift)**

This documentation covers:
- ✅ Secrets backend integration (AWS Secrets Manager, HashiCorp Vault, etc.)
- ✅ External Secrets Operator installation and configuration
- ✅ SecretStore and ClusterSecretStore resources
- ✅ Best practices for secrets management on OpenShift
- ✅ Security and compliance considerations

### Toolkit Secrets Backends

The toolkit supports multiple secrets backends via the `validated_patterns_secrets` role:

```bash
# External Secrets Operator (RECOMMENDED for Production)
# - Integrates with AWS Secrets Manager, Vault, etc.
# - Follows Red Hat best practices
# - Automatic secret rotation support
# - See: https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift

# Vault Backend (HashiCorp Vault)
# - Centralized secrets management
# - Secure storage and rotation
# - Access control and audit logging

# Sealed Secrets Backend
# - GitOps-friendly sealed secrets
# - Encrypted at rest in git
# - Easy to version control

# Kubernetes Native Secrets (Development Only)
# - Built-in Kubernetes secrets
# - Quick setup for testing
# - NOT recommended for production
```

### Managing Secrets with the Toolkit

The `validated_patterns_secrets` role handles secrets management:

```bash
# Location: ansible/roles/validated_patterns_secrets/

# This role handles:
# ✓ Secret backend configuration (External Secrets Operator, Vault, etc.)
# ✓ SecretStore and ClusterSecretStore setup
# ✓ Secret generation and validation
# ✓ Secret rotation and updates
# ✓ Access control and RBAC
# ✓ Compliance and audit logging

# See role README for complete documentation:
cat ansible/roles/validated_patterns_secrets/README.md
```

### Implementation Checklist

Before deploying your pattern, ensure:

- ✅ **Secrets backend selected** (External Secrets Operator recommended)
- ✅ **Backend credentials configured** (cloud provider, Vault, etc.)
- ✅ **SecretStore created** in the pattern namespace
- ✅ **Secrets strategy defined** (rotation frequency, access control)
- ✅ **Compliance reviewed** (PCI-DSS, HIPAA, SOC2 if applicable)
- ✅ **Audit logging enabled** (track all secret access)

### Reference Documentation

- 🔗 [Red Hat External Secrets Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift)
- 🔗 [Toolkit Secrets Role](ansible/roles/validated_patterns_secrets/README.md)
- 🔗 [AGENTS.md Secrets Guidelines](#secrets-management-guidelines)

For detailed implementation guidance, see the toolkit's `validated_patterns_secrets` role documentation and the AGENTS.md security guidelines.

---

## Part 4: Gitea Development Setup

### Deploy Gitea for Development

Gitea is deployed automatically during onboarding, but you can also deploy it separately:

```bash
# Deploy Gitea
make setup-gitea

# Access Gitea
# URL: https://gitea-gitea.apps.<cluster-domain>
# Default credentials: gitea / gitea
```

### Create Development Repository in Gitea

```bash
# Create development repository
make gitea-create-repo REPO_NAME=my-pattern

# Push project to Gitea
make gitea-push-project PROJECT_PATH=./my-pattern REPO_NAME=my-pattern

# View Gitea repositories
make gitea-list-repos
```

### Development Workflow in Gitea

1. **Create Branch for Development**
   ```bash
   cd my-pattern
   git branch -b feature/my-feature
   ```

2. **Make Changes Locally**
   ```bash
   # Edit files, test locally
   git add .
   git commit -m "feat: add my feature"
   ```

3. **Push to Gitea**
   ```bash
   git push origin feature/my-feature
   ```

4. **Create Pull Request in Gitea**
   - Navigate to Gitea UI
   - Create PR for merge to main

5. **Merge to Main**
   - Review changes
   - Merge to main branch

6. **Prepare Release**
   - Tag the release: `git tag v1.0.0`
   - Push tag: `git push origin v1.0.0`

---

## Part 5: Releasing to GitHub

### Push Releases Back to GitHub

When ready to release:

```bash
# Step 1: Create release branch
git checkout -b release/v1.0.0

# Step 2: Update version numbers
# Edit: values-global.yaml, pom.xml (or your version files)
# Update version to 1.0.0

# Step 3: Commit release changes
git add .
git commit -m "chore: release v1.0.0"

# Step 4: Push to GitHub
git remote add github https://github.com/yourorg/my-pattern.git
git push github release/v1.0.0

# Step 5: Create pull request on GitHub
# - Navigate to GitHub
# - Create PR from release/v1.0.0 to main
# - Merge after review

# Step 6: Tag and push release
git tag v1.0.0
git push github v1.0.0

# Step 7: Update Gitea main branch
git checkout main
git pull github main
git push gitea main
```

### Automated Release Script

For convenience, create a release script:

```bash
#!/bin/bash
# scripts/release.sh
VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/release.sh v1.0.0"
  exit 1
fi

# Update versions
sed -i "s/version:.*/version: $VERSION/" values-global.yaml

# Commit
git add .
git commit -m "chore: release $VERSION"
git tag "$VERSION"

# Push to Gitea
git push origin "$VERSION"

# Push to GitHub
git push github "$VERSION"

echo "✅ Release $VERSION created and pushed!"
```

---

## Part 6: Development Memory & Documentation

### What to Track in Development Memory

Create and maintain `DEVELOPMENT-MEMORY.md` for:

```markdown
# Development Memory: my-pattern

## 1. Architecture Overview
- [System design and components]
- [Data flow diagram]
- [Integration points]

## 2. Technology Stack
- Language: Python/Java/Go
- Framework: Flask/Spring Boot/Gin
- Database: PostgreSQL/MongoDB
- Container Runtime: Podman/Docker

## 3. Key Decisions
- [Why we chose this architecture]
- [Trade-offs made]
- [Alternatives considered and rejected]

## 4. Deployment Model
- [How the pattern deploys]
- [Required operators]
- [Resource requirements]

## 5. Development Workflow
- Local repo: gitea-gitea.apps.<cluster>
- Release repo: github.com/yourorg/my-pattern
- Development branch: main
- Release tags: vX.Y.Z

## 6. Known Limitations
- [What doesn't work yet]
- [Why some features are missing]
- [Technical debt]

## 7. Future Improvements
- [Planned enhancements]
- [Scalability considerations]
- [Security hardening]

## 8. Testing Strategy
- Unit tests: pytest/maven
- Integration tests: kind/minikube
- E2E tests: OpenShift cluster

## 9. Troubleshooting
- [Common issues and solutions]
- [Debug procedures]
- [Log locations]

## 10. Release Process
- Version format: vX.Y.Z (semantic versioning)
- Changelog: CHANGELOG.md
- Release frequency: [as needed / quarterly]
```

### Update Memory During Development

```bash
# Edit development memory
vim DEVELOPMENT-MEMORY.md

# Commit to Gitea
git add DEVELOPMENT-MEMORY.md
git commit -m "docs: update development memory"
git push origin main
```

---

## Part 7: Full Onboarding Examples

### Example 1: New Quarkus Application

```bash
# Create new pattern with Quarkus
make onboard-new-project PROJECT_NAME=my-quarkus-app

# View what was created
cd my-quarkus-app
ls -la

# Edit development memory
vim DEVELOPMENT-MEMORY.md

# Access Gitea and view repository
make gitea-list-repos

# Deploy pattern
make end2end-deployment

# Make changes
vim src/main/java/MyService.java
git add .
git commit -m "feat: add business logic"
git push origin main

# Release to GitHub
make release VERSION=v1.0.0
```

### Example 2: Existing Python Flask Project

```bash
# Onboard existing Flask project
make onboard-existing-project PROJECT_NAME=my-flask-app

# View integration guide
cat my-flask-app/.validated-patterns/INTEGRATION-GUIDE.md

# Decide what to copy (gradual integration)
# Option A: Copy Helm chart for GitOps deployment
cp -r my-flask-app/.validated-patterns/helm/my-flask-app ./my-flask-app/helm/

# Option B: Copy Ansible playbooks for automation
cp -r my-flask-app/.validated-patterns/ansible ./my-flask-app/

# Option C: Keep toolkit isolated (recommended for existing projects)
# Just use .validated-patterns/values-*.yaml and keep everything else separate

# Deploy to cluster using toolkit
cd my-flask-app/.validated-patterns
make end2end-deployment

# Develop locally in your main project
cd /path/to/my-flask-app
git pull  # Get latest from Gitea

# Make changes, test locally
python -m pytest tests/

# Push development
git add .
git commit -m "test: add unit tests"
git push origin develop

# Prepare release
git checkout -b release/v2.0.0
# Update version files (Flask app)
vim setup.py  # Update version
git add .
git commit -m "chore: release v2.0.0"
git push origin release/v2.0.0

# Create pull request and merge
# Then push to GitHub
git push github release/v2.0.0

# Toolkit files stay isolated in .validated-patterns/
# Your project remains clean and independent
```

### Example 3: Existing OpenShift AI Project

```bash
# Onboard OpenShift AI pattern
make onboard-existing-project PROJECT_NAME=ai-ml-patterns

# Check cluster for RHOAI operator
make cluster-info

# Update development memory with AI-specific info
vim DEVELOPMENT-MEMORY.md

# Deploy pattern with AI components
make end2end-deployment

# Access notebooks in Gitea
make gitea-list-repos

# Develop in OpenShift AI UI
# Push changes to Gitea
git add .
git commit -m "feat: train new model"
git push origin main

# Release trained model to GitHub
make release VERSION=v1.0.0
```

---

## Part 8: Troubleshooting

### Gitea Not Accessible

```bash
# Check Gitea pod status
oc get pods -n gitea

# View Gitea logs
oc logs -n gitea -l app=gitea

# Get Gitea route
oc get routes -n gitea

# Restart Gitea
oc rollout restart deployment/gitea -n gitea
```

### Push to Gitea Fails

```bash
# Check git remote configuration
git remote -v

# Verify Gitea credentials
oc get secret gitea-credentials -n gitea -o jsonpath='{.data.password}'

# Re-authenticate
git config --global credential.helper store
# Re-enter credentials when prompted
```

### Project Not Deploying

```bash
# Check prerequisites
make check-prerequisites

# View cluster info
make cluster-info

# Check pattern validity
make validate-pattern PATTERN_NAME=my-pattern

# Deploy in debug mode
make end2end-deployment-interactive
```

### Out of Sync Between Gitea and GitHub

```bash
# Fetch from both remotes
git fetch origin    # Gitea
git fetch github    # GitHub

# Compare branches
git log origin/main..github/main

# Sync Gitea from GitHub
git pull github main
git push origin main

# Or sync GitHub from Gitea
git pull origin main
git push github main
```

---

## Part 9: Best Practices

### Development Workflow

✅ **DO:**
- Use feature branches for development
- Write descriptive commit messages
- Update DEVELOPMENT-MEMORY.md regularly
- Test locally before pushing
- Create pull requests for code review
- Tag releases with semantic versions

❌ **DON'T:**
- Push directly to main branch
- Mix development and release work
- Forget to update documentation
- Deploy without prerequisites check
- Commit secrets or credentials

### Git Workflow

```
main (stable, ready for release)
  ↓
release/vX.Y.Z (release candidate)
  ↓
develop (integration branch)
  ↓
feature/my-feature (feature branches)
```

### Versioning

Follow semantic versioning:
- `vX.Y.Z` where:
  - `X` = Major (breaking changes)
  - `Y` = Minor (features)
  - `Z` = Patch (bug fixes)

Example: `v1.2.3`

---

## Part 10: Integration with CI/CD

### GitHub Actions for Auto-Release

Create `.github/workflows/release.yml`:

```yaml
name: Release to GitHub

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          draft: false
          prerelease: false
```

### ArgoCD Sync from GitHub

ArgoCD automatically deploys tagged releases:

```bash
# Tag release
git tag v1.0.0
git push github v1.0.0

# ArgoCD detects new tag and syncs
# View status
oc get applications -n openshift-gitops
```

---

## Part 11: Makefile Onboarding Targets

New targets to support onboarding:

```bash
make cluster-info
  → Analyze cluster and display requirements

make onboard-new-project PROJECT_NAME=name
  → Create and initialize new project

make onboard-existing-project PROJECT_NAME=name
  → Onboard existing project into toolkit

make onboard-status PROJECT_NAME=name
  → Show onboarding status and next steps

make setup-gitea
  → Deploy Gitea for development

make gitea-create-repo REPO_NAME=name
  → Create repository in Gitea

make gitea-push-project PROJECT_PATH=path REPO_NAME=name
  → Push project to Gitea

make gitea-list-repos
  → List all repositories in Gitea

make gitea-delete-repo REPO_NAME=name
  → Delete repository from Gitea

make release VERSION=vX.Y.Z
  → Push release to GitHub
```

---

## Part 12: Support & Resources

### Getting Help

```bash
# Show cluster info
make cluster-info

# Show onboarding help
make onboard-help

# Check prerequisites
make check-prerequisites

# View deployment workflow
make end2end-help

# View logs
oc logs -n openshift-gitops -f
```

### Documentation References

- [Deployment Workflow](DEPLOYMENT-WORKFLOW.md)
- [Developer Guide](docs/DEVELOPER-GUIDE.md)
- [End-User Guide](docs/END-USER-GUIDE.md)
- [Architecture](docs/ARCHITECTURE-DIAGRAMS.md)
- [Ansible Roles Reference](docs/ANSIBLE-ROLES-REFERENCE.md)

### Common Commands

```bash
# Full deployment
make end2end-deployment

# Development setup
make setup-gitea

# Status checks
make cluster-info
make check-prerequisites

# Cleanup
make end2end-cleanup

# Documentation
make end2end-help
make onboard-help
```

---

## Next Steps

1. **Choose Your Path:**
   - New Project → `make onboard-new-project`
   - Existing Project → `make onboard-existing-project`

2. **Setup Development:**
   - Review `DEVELOPMENT-MEMORY.md`
   - Deploy Gitea
   - Initialize repositories

3. **Deploy to Cluster:**
   - `make check-prerequisites`
   - `make end2end-deployment`

4. **Start Developing:**
   - Create feature branches
   - Make changes
   - Push to Gitea

5. **Release:**
   - Tag releases with versions
   - Push to GitHub
   - Monitor ArgoCD for auto-sync

---

**Happy Onboarding! 🚀**

For questions or issues, check [docs/TROUBLESHOOTING-COMPREHENSIVE.md](docs/TROUBLESHOOTING-COMPREHENSIVE.md) or [SUPPORT.md](SUPPORT.md)
