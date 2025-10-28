# ADR-008: Repository Rename for Hard Fork

**Status:** Proposed
**Date:** 2025-01-24
**Decision Makers:** Development Team, Repository Owner
**Consulted:** End Users, Community
**Informed:** Stakeholders

## Context and Problem Statement

This repository started as `validated-patterns-ansible-toolkit`, focused on building Ansible execution environments. However, it has evolved into a comprehensive template for deploying Validated Patterns on OpenShift with:

- Ansible roles for idempotent pattern deployment
- Quarkus management application
- Tekton validation pipelines
- Gitea development environment
- Ansible Navigator integration
- Complete documentation and tutorials

The current name `validated-patterns-ansible-toolkit` no longer accurately reflects the repository's purpose and scope. Since this is a hard fork with significant new functionality, we should rename it to better communicate its value to end users.

## Decision Drivers

* **Clarity**: Name should clearly indicate the repository's purpose
* **Discoverability**: Easy to find when searching for Validated Patterns tools
* **Branding**: Align with Validated Patterns ecosystem
* **SEO**: Improve search engine visibility
* **User Experience**: Set correct expectations for new users
* **Community**: Avoid confusion with original validated-patterns-ansible-toolkit

## Considered Options

### Option 1: Keep Current Name
- `validated-patterns-ansible-toolkit`
- **Rejected**: Doesn't reflect new purpose, confusing for users

### Option 2: Generic Template Name
- `validated-patterns-template`
- **Pros**: Clear, simple, descriptive
- **Cons**: Doesn't highlight key features

### Option 3: Deployment-Focused Name
- `validated-patterns-deployer`
- **Pros**: Action-oriented, clear purpose
- **Cons**: Doesn't capture full scope (validation, management, etc.)

### Option 4: Comprehensive Toolkit Name (Recommended)
- `validated-patterns-toolkit`
- **Pros**: Captures full scope, professional, extensible
- **Cons**: Slightly longer

### Option 5: Automation-Focused Name
- `validated-patterns-automation`
- **Pros**: Highlights automation aspect
- **Cons**: Doesn't capture management and validation features

## Decision Outcome

**Chosen option:** Option 4 - `validated-patterns-toolkit`

### Rationale

The name `validated-patterns-toolkit` best represents the repository because:

1. **Comprehensive**: Indicates it's more than just a deployer
2. **Professional**: "Toolkit" suggests a complete, well-integrated solution
3. **Extensible**: Room to add more tools and features
4. **Clear Purpose**: Immediately communicates it's for Validated Patterns
5. **Community Aligned**: Fits with Validated Patterns naming conventions
6. **Searchable**: Easy to find when searching for Validated Patterns tools

### Alternative Names Considered

If `validated-patterns-toolkit` is not preferred, these alternatives are also good:

1. **`validated-patterns-deployer`** - More focused on deployment
2. **`validated-patterns-automation`** - Emphasizes automation
3. **`validated-patterns-platform`** - Suggests complete platform
4. **`validated-patterns-manager`** - Highlights management capabilities

## Implementation Plan

### 1. Repository Rename

```bash
# On GitHub
# Settings → General → Repository name
# Change: validated-patterns-ansible-toolkit → validated-patterns-toolkit

# GitHub automatically creates redirect from old name
```

### 2. Update Repository Description

**New Description:**
```
Comprehensive toolkit for deploying, validating, and managing Red Hat Validated Patterns on OpenShift.
Includes Ansible roles, Quarkus management app, Tekton validation, and Gitea development environment.
```

**Topics/Tags:**
- `validated-patterns`
- `openshift`
- `ansible`
- `gitops`
- `quarkus`
- `tekton`
- `ansible-navigator`
- `execution-environment`

### 3. Update Documentation

Update all references in documentation:

```bash
# Files to update
- README.md
- docs/adr/*.md
- docs/*.md
- Makefile (comments)
- execution-environment.yml (comments)
- ansible-navigator.yml (comments)
- gitea/README.md
- All tutorial files
```

**Find and replace:**
```bash
# Old references
validated-patterns-ansible-toolkit

# New references
validated-patterns-toolkit
```

### 4. Update Container Image Names

```makefile
# Makefile - Update default image name
TARGET_NAME ?= validated-patterns-ee

# Or more descriptive
TARGET_NAME ?= validated-patterns-toolkit-ee
```

### 5. Update Git Remotes (For Contributors)

Contributors will need to update their remotes:

```bash
# Update remote URL
git remote set-url origin https://github.com/tosin2013/validated-patterns-toolkit.git

# Or if using SSH
git remote set-url origin git@github.com:tosin2013/validated-patterns-toolkit.git

# Verify
git remote -v
```

### 6. Communication Plan

**Announcement Template:**

```markdown
# Repository Renamed: validated-patterns-ansible-toolkit → validated-patterns-toolkit

We've renamed this repository to better reflect its evolved purpose!

## What Changed?
- **Old Name**: validated-patterns-ansible-toolkit
- **New Name**: validated-patterns-toolkit
- **URL**: https://github.com/tosin2013/validated-patterns-toolkit

## Why?
This repository has grown from a simple execution environment builder into a
comprehensive toolkit for deploying and managing Validated Patterns, including:
- Ansible roles for idempotent deployment
- Quarkus management application
- Tekton validation pipelines
- Gitea development environment
- Complete documentation and tutorials

## What You Need to Do
GitHub automatically redirects the old URL, but we recommend updating your remotes:

```bash
git remote set-url origin https://github.com/tosin2013/validated-patterns-toolkit.git
```

## Questions?
See our [documentation](docs/GETTING-STARTED-WITH-PLANNING.md) or open an issue!
```

### 7. Update External References

Update references in:
- GitHub organization/profile README
- Blog posts or articles
- Social media profiles
- Documentation sites
- Container registry descriptions

## Migration Guide for Users

### For Existing Users

```bash
# 1. Update your local repository remote
cd validated-patterns-ansible-toolkit
git remote set-url origin https://github.com/tosin2013/validated-patterns-toolkit.git

# 2. Optionally rename your local directory
cd ..
mv validated-patterns-ansible-toolkit validated-patterns-toolkit
cd validated-patterns-toolkit

# 3. Pull latest changes
git pull

# 4. Rebuild execution environment with new name
make clean build
```

### For New Users

```bash
# Clone with new name
git clone https://github.com/tosin2013/validated-patterns-toolkit.git
cd validated-patterns-toolkit

# Follow quick start guide
make deploy-pattern PATTERN_NAME=multicloud-gitops
```

## Impact on Existing Deployments

### Container Images

**Current:**
```yaml
execution-environment:
  image: localhost/ansible-ee-minimal:v5
```

**After Rename (Recommended):**
```yaml
execution-environment:
  image: localhost/validated-patterns-ee:v5
  # Or
  image: quay.io/validated-patterns/toolkit-ee:latest
```

### Playbook References

No changes needed - playbooks reference relative paths:
```yaml
# Still works
ansible-navigator run ansible/playbooks/deploy_pattern.yml
```

### Documentation Links

GitHub automatically redirects old URLs:
- `github.com/tosin2013/validated-patterns-ansible-toolkit` → `github.com/tosin2013/validated-patterns-toolkit`

## Consequences

### Positive

* **Clarity**: Name accurately reflects repository purpose
* **Discoverability**: Easier to find when searching for Validated Patterns tools
* **Professional**: More polished, production-ready impression
* **Extensible**: Room to add more features without name confusion
* **Community**: Better alignment with Validated Patterns ecosystem
* **SEO**: Improved search engine rankings for relevant terms
* **Branding**: Stronger identity and recognition

### Negative

* **Disruption**: Existing users need to update remotes
* **Documentation**: Need to update all references
* **Confusion**: Short-term confusion during transition
* **Links**: External links may need updating

### Neutral

* **GitHub Redirect**: Old URLs automatically redirect (permanent)
* **Git History**: All history preserved
* **Issues/PRs**: All preserved with new URL

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| User confusion during transition | Medium | Clear announcement, migration guide |
| Broken external links | Low | GitHub auto-redirects, update known links |
| Container image confusion | Medium | Clear documentation, support both names temporarily |
| Lost SEO ranking | Low | GitHub redirects preserve SEO, update references |
| Fork relationship unclear | Low | Document as hard fork in README |

## Timeline

### Immediate (Day 1)
- [ ] Rename repository on GitHub
- [ ] Update README.md
- [ ] Update repository description and topics
- [ ] Post announcement

### Week 1
- [ ] Update all documentation files
- [ ] Update Makefile and configuration files
- [ ] Update container image names
- [ ] Create migration guide

### Week 2
- [ ] Update external references
- [ ] Notify community
- [ ] Update container registry descriptions
- [ ] Monitor for issues

### Ongoing
- [ ] Support both old and new image names temporarily
- [ ] Help users migrate
- [ ] Update any discovered references

## Verification

After rename, verify:

```bash
# 1. Repository accessible at new URL
curl -I https://github.com/tosin2013/validated-patterns-toolkit

# 2. Old URL redirects
curl -I https://github.com/tosin2013/validated-patterns-ansible-toolkit

# 3. Clone works with new name
git clone https://github.com/tosin2013/validated-patterns-toolkit.git

# 4. Documentation updated
grep -r "validated-patterns-ansible-toolkit" docs/ | wc -l  # Should be 0 or minimal

# 5. Container images build with new name
make build
podman images | grep validated-patterns
```

## Alternative Naming Schemes

If `validated-patterns-toolkit` doesn't resonate, consider these alternatives:

### By Function
- `validated-patterns-deployer` - Deployment focused
- `validated-patterns-manager` - Management focused
- `validated-patterns-automation` - Automation focused

### By Scope
- `validated-patterns-platform` - Complete platform
- `validated-patterns-framework` - Framework for patterns
- `validated-patterns-suite` - Suite of tools

### By Approach
- `validated-patterns-gitops` - GitOps focused
- `validated-patterns-operator` - Operator-like (though not a real operator)
- `validated-patterns-controller` - Controller pattern

## References

* [GitHub Repository Renaming](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository)
* [Validated Patterns](https://validatedpatterns.io/)
* [Semantic Naming Best Practices](https://github.com/naming-convention/naming-convention-guides)

## Decision

**Recommended Name:** `validated-patterns-toolkit`

**Approval Required From:**
- Repository Owner (tosin2013)
- Core Contributors
- Community Feedback (optional)

**Next Steps:**
1. Get approval from repository owner
2. Announce rename plan to community
3. Execute rename on agreed date
4. Update all documentation
5. Support users during transition
