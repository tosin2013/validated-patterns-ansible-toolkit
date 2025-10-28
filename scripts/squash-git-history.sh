#!/bin/bash
# Squash git history to remove exposed secrets
# This creates a fresh repository with a single initial commit

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  WARNING: This will DESTROY all git history!                  ║${NC}"
echo -e "${RED}║  This action is IRREVERSIBLE!                                 ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This script will:${NC}"
echo "  1. Create a backup of the current repository"
echo "  2. Remove all git history"
echo "  3. Create a fresh initial commit"
echo "  4. Preserve all current files and changes"
echo ""
echo -e "${YELLOW}Why we're doing this:${NC}"
echo "  - Remove exposed Gitea token from git history"
echo "  - Clean slate for new repository migration"
echo "  - Prevent token from being pushed to GitHub"
echo ""

# Confirmation
read -p "Do you want to proceed? (type 'yes' to continue): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Aborted.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Starting git history squash...${NC}"

# Step 1: Create backup
BACKUP_DIR="../ansible-execution-environment-backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${BLUE}[1/6] Creating backup at: $BACKUP_DIR${NC}"
cp -r . "$BACKUP_DIR"
echo -e "${GREEN}✓ Backup created${NC}"

# Step 2: Save current branch name
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}[2/6] Current branch: $CURRENT_BRANCH${NC}"

# Step 3: Get current commit message for reference
LAST_COMMIT_MSG=$(git log -1 --pretty=%B)
echo -e "${BLUE}[3/6] Last commit message: $LAST_COMMIT_MSG${NC}"

# Step 4: Remove .git directory
echo -e "${BLUE}[4/6] Removing .git directory...${NC}"
rm -rf .git

# Step 5: Initialize fresh repository
echo -e "${BLUE}[5/6] Initializing fresh repository...${NC}"
git init
git branch -M main

# Configure git user if not set
if ! git config user.name > /dev/null 2>&1; then
    git config user.name "Tosin Akinosho"
fi
if ! git config user.email > /dev/null 2>&1; then
    git config user.email "takinosh@redhat.com"
fi

# Step 6: Create initial commit
echo -e "${BLUE}[6/6] Creating initial commit...${NC}"

# Stage all files
git add -A

# Create comprehensive initial commit message
cat > /tmp/commit-message.txt <<'EOF'
feat: Initial commit - Validated Patterns Ansible Toolkit v1.0

This is a fresh repository created from ansible-execution-environment
with a clean git history to remove exposed secrets.

## What's Included

### Core Components
- 7 Ansible roles for Validated Patterns deployment
- Quarkus reference application with Helm charts
- Comprehensive documentation (Diataxis framework)
- Integration tests and validation playbooks
- Pre-commit hooks with Gitleaks secret detection

### Ansible Roles
1. validated_patterns_prerequisites - Cluster validation
2. validated_patterns_common - Common utilities and helpers
3. validated_patterns_operator - VP Operator deployment
4. validated_patterns_deploy - Pattern deployment
5. validated_patterns_gitea - Gitea setup for development
6. validated_patterns_secrets - Secrets management
7. validated_patterns_validate - Deployment validation

### Reference Application
- Quarkus REST API with OpenShift BuildConfig
- Helm charts for dev, hub, and prod environments
- Tekton CI/CD pipelines
- Health checks and metrics endpoints

### Documentation
- 14 Architecture Decision Records (ADRs)
- Tutorials, how-to guides, reference docs
- Developer and end-user guides
- Comprehensive troubleshooting guide

### Security
- Pre-commit hooks with Gitleaks
- Secret detection with 8 custom rules
- YAML validation and linting
- Security advisory process

## Repository Migration

This repository was migrated from:
- OLD: github.com/tosin2013/ansible-execution-environment
- NEW: github.com/tosin2013/validated-patterns-ansible-toolkit

Git history was squashed to remove exposed secrets and provide
a clean starting point for the community.

## Project Status

- Phase 1: Repository Migration & Security Setup (90% complete)
- Phase 2: Quarkus Reference App (100% complete)
- Phase 3: Testing & Validation (planned)
- Phase 4: Documentation & Release (in progress)

## Getting Started

```bash
# Clone the repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Build execution environment
make build

# Run tests
make test
```

## Contributing

See CONTRIBUTING.md for guidelines on contributing to this project.

## License

Apache License 2.0

## Maintainers

- @tosin2013 - Tosin Akinosho <tosin.akinosho@gmail.com>

---

Previous repository history archived for reference.
Security advisory: docs/SECURITY-ADVISORY-001-EXPOSED-GITEA-TOKEN.md
EOF

git commit -F /tmp/commit-message.txt
rm /tmp/commit-message.txt

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Git history squashed successfully!                           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  - Backup location: $BACKUP_DIR"
echo "  - New repository initialized with single commit"
echo "  - All files preserved"
echo "  - Git history removed (including exposed secrets)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Verify files are intact: ls -la"
echo "  2. Check git status: git status"
echo "  3. Review commit: git log"
echo "  4. Add new remote: git remote add origin https://github.com/tosin2013/validated-patterns-ansible-toolkit.git"
echo "  5. Push to GitHub: git push -u origin main --force"
echo ""
echo -e "${BLUE}Note: The old repository history is backed up at:${NC}"
echo "  $BACKUP_DIR"
echo ""
echo -e "${GREEN}✓ Ready for migration to new repository!${NC}"

