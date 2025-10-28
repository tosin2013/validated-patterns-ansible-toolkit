# GitHub Actions for Ansible Collection

This document describes the GitHub Actions workflows for building, testing, and publishing the Ansible Collection.

## Table of Contents

- [Workflows Overview](#workflows-overview)
- [Setup Requirements](#setup-requirements)
- [Publishing Workflow](#publishing-workflow)
- [Testing Workflow](#testing-workflow)
- [Manual Publishing](#manual-publishing)
- [Troubleshooting](#troubleshooting)

## Workflows Overview

### 1. Publish Collection (`publish-collection.yml`)

**Purpose**: Automatically build and publish the collection to Ansible Galaxy

**Triggers**:
- **Automatic**: When a version tag is pushed (e.g., `v1.0.0`, `v1.1.0`)
- **Manual**: Via workflow_dispatch with version input

**What it does**:
1. ✅ Validates collection structure
2. ✅ Updates galaxy.yml version
3. ✅ Runs yamllint validation
4. ✅ Builds collection tarball
5. ✅ Tests local installation
6. ✅ Publishes to Ansible Galaxy
7. ✅ Creates GitHub Release with tarball
8. ✅ Verifies Galaxy publication

### 2. Test Collection (`collection-test.yml`)

**Purpose**: Test collection on every push and pull request

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Only when `collection/` files change

**What it does**:
1. ✅ Lints collection with yamllint and ansible-lint
2. ✅ Validates collection structure
3. ✅ Builds collection tarball
4. ✅ Tests installation
5. ✅ Tests all 8 roles individually
6. ✅ Comments on PR with build status

## Setup Requirements

### 1. Configure Ansible Galaxy API Token

**Step 1**: Get your Galaxy API token
1. Go to https://galaxy.ansible.com/
2. Log in with your account
3. Navigate to **Preferences** → **API Key**
4. Click **Show API Key** or **Generate New Token**
5. Copy the token

**Step 2**: Add token to GitHub Secrets
1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `GALAXY_API_KEY`
5. Value: Paste your Galaxy API token
6. Click **Add secret**

### 2. Verify Namespace

Ensure you have the `tosin2013` namespace on Ansible Galaxy:
- Visit: https://galaxy.ansible.com/tosin2013
- If not available, request namespace or update `collection/galaxy.yml`

## Publishing Workflow

### Automatic Publishing (Recommended)

**Step 1**: Update version in `collection/galaxy.yml`

```yaml
version: 1.1.0  # Update this
```

**Step 2**: Update `collection/CHANGELOG.rst`

Add release notes for the new version.

**Step 3**: Commit and push changes

```bash
git add collection/galaxy.yml collection/CHANGELOG.rst
git commit -m "chore: Bump version to 1.1.0"
git push origin main
```

**Step 4**: Create and push version tag

```bash
git tag v1.1.0
git push origin v1.1.0
```

**Step 5**: Monitor workflow

1. Go to **Actions** tab in GitHub
2. Watch the **Publish Ansible Collection to Galaxy** workflow
3. Verify successful completion

**Step 6**: Verify publication

```bash
ansible-galaxy collection install tosin2013.validated_patterns_toolkit:1.1.0
```

### Manual Publishing

**Option 1**: Via GitHub UI

1. Go to **Actions** tab
2. Select **Publish Ansible Collection to Galaxy**
3. Click **Run workflow**
4. Enter version (e.g., `1.1.0`)
5. Choose dry run option (optional)
6. Click **Run workflow**

**Option 2**: Via GitHub CLI

```bash
gh workflow run publish-collection.yml \
  -f version=1.1.0 \
  -f dry_run=false
```

### Dry Run (Test Without Publishing)

Test the build process without publishing:

```bash
gh workflow run publish-collection.yml \
  -f version=1.1.0 \
  -f dry_run=true
```

## Testing Workflow

### Automatic Testing

The test workflow runs automatically on:
- Every push to `main` or `develop`
- Every pull request to `main` or `develop`

### Manual Testing

Run tests manually:

```bash
gh workflow run collection-test.yml
```

### What Gets Tested

**Lint Job**:
- yamllint validation
- ansible-lint validation

**Build Job**:
- Collection structure validation
- All 8 roles present
- Tarball creation
- Installation test
- PR comment with results

**Test Roles Job** (Matrix):
- Individual role structure validation
- Syntax checking for each role
- Runs for all 8 roles in parallel

## Workflow Outputs

### Artifacts

Both workflows create artifacts:

**Publish Workflow**:
- `collection-tarball` (30 days retention)
- Attached to GitHub Release

**Test Workflow**:
- `collection-tarball-pr-{number}` (7 days retention)

### GitHub Release

When publishing via tag, a GitHub Release is created with:
- Collection tarball attached
- Installation instructions
- Links to Galaxy and documentation
- Release notes from CHANGELOG.rst

## Troubleshooting

### Issue: GALAXY_API_KEY not configured

**Error**: `ERROR: GALAXY_API_KEY secret not configured`

**Solution**:
1. Verify secret exists: **Settings** → **Secrets and variables** → **Actions**
2. Check secret name is exactly `GALAXY_API_KEY`
3. Regenerate token if expired

### Issue: Namespace not found

**Error**: `ERROR: Namespace 'tosin2013' not found`

**Solution**:
1. Verify namespace exists: https://galaxy.ansible.com/tosin2013
2. Request namespace if needed
3. Or update `collection/galaxy.yml` with your namespace

### Issue: Version already exists

**Error**: `ERROR: Version 1.0.0 already exists`

**Solution**:
1. Bump version in `collection/galaxy.yml`
2. Create new tag with updated version
3. Cannot overwrite existing versions on Galaxy

### Issue: yamllint failures

**Error**: Yamllint reports errors

**Solution**:
1. Run locally: `yamllint collection/`
2. Fix reported issues
3. Commit and push fixes
4. Note: yamllint is non-blocking in workflows

### Issue: Collection not available after publishing

**Error**: Cannot install collection immediately after publishing

**Solution**:
- Wait 1-2 minutes for Galaxy to process
- Check Galaxy page: https://galaxy.ansible.com/tosin2013/validated_patterns_toolkit
- Verify version appears in version list

## Version Bumping Strategy

### Semantic Versioning

Follow semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features, backward compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backward compatible

### Release Checklist

- [ ] Update `collection/galaxy.yml` version
- [ ] Update `collection/CHANGELOG.rst` with release notes
- [ ] Update `README.md` if needed
- [ ] Commit changes: `git commit -m "chore: Bump version to X.Y.Z"`
- [ ] Push to main: `git push origin main`
- [ ] Create tag: `git tag vX.Y.Z`
- [ ] Push tag: `git push origin vX.Y.Z`
- [ ] Monitor GitHub Actions workflow
- [ ] Verify Galaxy publication
- [ ] Test installation: `ansible-galaxy collection install tosin2013.validated_patterns_toolkit:X.Y.Z`
- [ ] Announce release (optional)

## Monitoring

### Check Workflow Status

**Via GitHub UI**:
1. Go to **Actions** tab
2. View recent workflow runs
3. Click on run for details

**Via GitHub CLI**:
```bash
# List recent runs
gh run list --workflow=publish-collection.yml

# View specific run
gh run view <run-id>

# Watch live run
gh run watch
```

### Check Galaxy Status

**Collection Page**:
https://galaxy.ansible.com/tosin2013/validated_patterns_toolkit

**API Check**:
```bash
curl https://galaxy.ansible.com/api/v3/collections/tosin2013/validated_patterns_toolkit/
```

## Additional Resources

- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Ansible Galaxy Docs**: https://docs.ansible.com/ansible/latest/galaxy/user_guide.html
- **Collection Publishing**: https://docs.ansible.com/ansible/latest/dev_guide/developing_collections_distributing.html
- **Semantic Versioning**: https://semver.org/

