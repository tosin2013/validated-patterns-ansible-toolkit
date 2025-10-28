#!/bin/bash
# Helper script to update references after repository rename
# From: validated-patterns-ansible-toolkit
# To: validated-patterns-toolkit

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OLD_NAME="validated-patterns-ansible-toolkit"
NEW_NAME="validated-patterns-toolkit"
OLD_IMAGE="ansible-ee-minimal"
NEW_IMAGE="validated-patterns-ee"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if we're in the right directory
check_directory() {
    if [ ! -f "execution-environment.yml" ]; then
        log_error "This script must be run from the repository root"
        exit 1
    fi

    log_info "Running from repository root: $(pwd)"
}

# Backup files before making changes
backup_files() {
    log_step "Creating backup..."

    local backup_dir="backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    # Backup key files
    cp README.md "$backup_dir/" 2>/dev/null || true
    cp Makefile "$backup_dir/" 2>/dev/null || true
    cp ansible-navigator.yml "$backup_dir/" 2>/dev/null || true

    log_info "Backup created in: $backup_dir"
}

# Update documentation files
update_documentation() {
    log_step "Updating documentation files..."

    local files=(
        "README.md"
        "docs/PROJECT-ROADMAP.md"
        "docs/PLANNING-SUMMARY.md"
        "docs/GETTING-STARTED-WITH-PLANNING.md"
        "docs/adr/README.md"
        "docs/adr/ADR-001-project-vision-and-scope.md"
        "docs/adr/ADR-007-ansible-navigator-deployment.md"
        "docs/tutorials/quick-start-ansible-navigator.md"
        "gitea/README.md"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            log_info "Updating: $file"
            sed -i.bak "s|$OLD_NAME|$NEW_NAME|g" "$file"
            rm -f "${file}.bak"
        else
            log_warn "File not found: $file"
        fi
    done
}

# Update configuration files
update_configuration() {
    log_step "Updating configuration files..."

    # Update Makefile
    if [ -f "Makefile" ]; then
        log_info "Updating: Makefile"
        sed -i.bak "s|TARGET_NAME ?= $OLD_IMAGE|TARGET_NAME ?= $NEW_IMAGE|g" Makefile
        sed -i.bak "s|# Ansible Automation Platform - Makefile for Execution Environments|# Validated Patterns Toolkit - Makefile|g" Makefile
        rm -f Makefile.bak
    fi

    # Update ansible-navigator.yml
    if [ -f "ansible-navigator.yml" ]; then
        log_info "Updating: ansible-navigator.yml"
        sed -i.bak "s|$OLD_IMAGE|$NEW_IMAGE|g" ansible-navigator.yml
        sed -i.bak "s|# Ansible Navigator Configuration for Validated Patterns Template|# Ansible Navigator Configuration for Validated Patterns Toolkit|g" ansible-navigator.yml
        rm -f ansible-navigator.yml.bak
    fi

    # Update execution-environment.yml
    if [ -f "execution-environment.yml" ]; then
        log_info "Updating: execution-environment.yml"
        sed -i.bak "s|Validated Patterns Execution Environment|Validated Patterns Toolkit Execution Environment|g" execution-environment.yml
        rm -f execution-environment.yml.bak
    fi
}

# Update README.md with new name and description
update_readme() {
    log_step "Updating README.md with new description..."

    if [ -f "README.md" ]; then
        # Add a note about the rename at the top
        cat > README.md.new << 'EOF'
# Validated Patterns Toolkit

> **Note:** This repository was renamed from `validated-patterns-ansible-toolkit` to better reflect its comprehensive scope.
> GitHub automatically redirects the old URL. See [ADR-008](docs/adr/ADR-008-repository-rename.md) for details.

Comprehensive toolkit for deploying, validating, and managing Red Hat Validated Patterns on OpenShift.

## What's Included

- **Ansible Roles**: Idempotent deployment automation
- **Quarkus Application**: Management interface and REST API
- **Tekton Pipelines**: Multi-stage validation framework
- **Gitea Environment**: Integrated development environment
- **Ansible Navigator**: Containerized execution with Podman
- **Complete Documentation**: Tutorials, ADRs, and guides

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/tosin2013/validated-patterns-toolkit.git
cd validated-patterns-toolkit

# 2. Login to OpenShift
oc login

# 3. Deploy a pattern
make deploy-pattern PATTERN_NAME=multicloud-gitops
```

## Documentation

- **[Quick Start Guide](docs/tutorials/quick-start-ansible-navigator.md)** - Get started in 5 minutes
- **[Architecture Decision Records](docs/adr/README.md)** - Design decisions and rationale
- **[Project Roadmap](docs/PROJECT-ROADMAP.md)** - Implementation plan
- **[Development Rules](docs/adr/ADR-DEVELOPMENT-RULES.md)** - Coding standards and guidelines

## Features

### Deployment
- Single-command pattern deployment
- Idempotent Ansible roles
- Support for multiple patterns
- Execution context handling (root/subdirectory)

### Validation
- Pre-deployment checks
- During-deployment monitoring
- Post-deployment verification
- Continuous validation with Tekton

### Management
- Quarkus-based management application
- REST API for automation
- Web UI for visualization
- Real-time monitoring

### Development
- Gitea on OpenShift
- Repository mirroring
- Multi-user support
- Air-gapped capability

## Supported Patterns

- [Multicloud GitOps](https://validatedpatterns.io/patterns/multicloud-gitops/)
- [Industrial Edge](https://validatedpatterns.io/patterns/industrial-edge/)
- [Medical Diagnosis](https://validatedpatterns.io/patterns/medical-diagnosis/)

## Prerequisites

- Podman
- ansible-navigator (`pip install ansible-navigator`)
- OpenShift CLI (oc)
- Access to an OpenShift cluster

## Usage

### Deploy a Pattern

```bash
make deploy-pattern PATTERN_NAME=multicloud-gitops
```

### Validate Deployment

```bash
make validate-pattern PATTERN_NAME=multicloud-gitops
```

### Setup Gitea

```bash
make setup-gitea
```

### Interactive Mode (Debugging)

```bash
make deploy-pattern-interactive PATTERN_NAME=multicloud-gitops
```

## Contributing

See [Development Rules](docs/adr/ADR-DEVELOPMENT-RULES.md) and [Getting Started Guide](docs/GETTING-STARTED-WITH-PLANNING.md).

## License

[Your License Here]

## References

- [Validated Patterns](https://validatedpatterns.io/)
- [validatedpatterns/common](https://github.com/validatedpatterns/common)
- [Ansible Navigator](https://ansible.readthedocs.io/projects/navigator/)
- [OpenShift GitOps](https://docs.openshift.com/gitops/)

EOF

        mv README.md.new README.md
        log_info "README.md updated with new content"
    fi
}

# Update git remote (if needed)
update_git_remote() {
    log_step "Checking git remote..."

    local current_remote=$(git remote get-url origin 2>/dev/null || echo "")

    if [[ "$current_remote" == *"$OLD_NAME"* ]]; then
        log_warn "Git remote still points to old name: $current_remote"
        echo
        echo "To update your git remote, run:"
        echo "  git remote set-url origin https://github.com/tosin2013/$NEW_NAME.git"
        echo
        echo "Or for SSH:"
        echo "  git remote set-url origin git@github.com:tosin2013/$NEW_NAME.git"
    else
        log_info "Git remote is up to date"
    fi
}

# Generate summary report
generate_report() {
    log_step "Generating summary report..."

    local report_file="rename-report-$(date +%Y%m%d-%H%M%S).txt"

    cat > "$report_file" << EOF
Repository Rename Summary
=========================
Date: $(date)
Old Name: $OLD_NAME
New Name: $NEW_NAME

Files Updated:
--------------
EOF

    # List updated files
    find . -name "*.md" -o -name "Makefile" -o -name "*.yml" | while read -r file; do
        if grep -q "$NEW_NAME" "$file" 2>/dev/null; then
            echo "  ✓ $file" >> "$report_file"
        fi
    done

    cat >> "$report_file" << EOF

Next Steps:
-----------
1. Review changes: git diff
2. Test build: make clean build
3. Commit changes: git add -A && git commit -m "Rename repository to $NEW_NAME"
4. Update remote: git remote set-url origin https://github.com/tosin2013/$NEW_NAME.git
5. Push changes: git push

References:
-----------
- ADR-008: docs/adr/ADR-008-repository-rename.md
- Backup: backup-*/

EOF

    log_info "Report saved to: $report_file"
    echo
    cat "$report_file"
}

# Main execution
main() {
    echo
    log_info "Repository Rename Helper Script"
    log_info "From: $OLD_NAME"
    log_info "To: $NEW_NAME"
    echo

    # Confirm with user
    read -p "This will update files in the repository. Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Aborted by user"
        exit 0
    fi

    check_directory
    backup_files
    update_documentation
    update_configuration
    update_readme
    update_git_remote
    generate_report

    echo
    log_info "Repository rename updates complete!"
    log_info "Review changes with: git diff"
    log_info "See ADR-008 for full migration guide: docs/adr/ADR-008-repository-rename.md"
}

# Run main function
main "$@"
