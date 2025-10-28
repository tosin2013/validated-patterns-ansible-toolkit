# Task 3 & 4 Strategy: Git Repository Setup

## Current Situation

### ✅ What We Have
1. **ArgoCD Infrastructure** (from Task 2)
   - `common-gitops` ArgoCD instance deployed
   - 6/6 pods running in `common-common` namespace
   - Ready to deploy applications via GitOps

2. **Gitea Infrastructure** (Pre-existing)
   - Gitea operator v2.0.8 installed
   - Gitea instance `gitea-with-admin` deployed
   - URL: https://gitea-with-admin-gitea.apps.cluster-4l957.4l957.sandbox1206.opentlc.com
   - Admin user: `opentlc-mgr`

3. **Quarkus Reference Application**
   - Located in: `quarkus-reference-app/`
   - Kustomize manifests ready
   - Dev overlay: `quarkus-reference-app/k8s/overlays/dev`

### ❌ What We're Missing
1. **Git Repository in Gitea**
   - Repository `validated-patterns-ansible-toolkit` does not exist in Gitea
   - Need to create repository and push code

## Task Dependency

```
Task 2 (✅ Complete)
    ↓
Task 4 (🔄 In Progress) ← We need to do this FIRST
    ↓
Task 3 (⏳ Blocked)
```

**Why Task 4 Must Come First:**
- Task 3 deploys the Quarkus app via ArgoCD
- ArgoCD needs a Git repository to sync from
- We're using Gitea (local Git server) not GitHub
- Task 4 creates the Gitea repository

## Revised Approach

### Phase 1: Task 4 - Setup Gitea Repository (DO THIS FIRST)

**Objective:** Create and populate Gitea repository with our code

**Steps:**
1. Get Gitea admin credentials
2. Create organization/user in Gitea (if needed)
3. Create repository: `validated-patterns-ansible-toolkit`
4. Push code to Gitea:
   - Quarkus reference app
   - Kubernetes manifests
   - Kustomize overlays

**Test Playbook:** `tests/week8/test_gitea.yml` (to be created)

**Success Criteria:**
- ✅ Repository exists in Gitea
- ✅ Code is accessible via HTTPS
- ✅ Kustomize manifests are present
- ✅ Repository URL: `https://gitea-with-admin-gitea.apps.cluster-4l957.4l957.sandbox1206.opentlc.com/opentlc-mgr/validated-patterns-ansible-toolkit.git`

### Phase 2: Task 3 - Deploy via ArgoCD (DO THIS SECOND)

**Objective:** Deploy Quarkus app using ArgoCD and Gitea repository

**Steps:**
1. Create ArgoCD Application pointing to Gitea repo
2. Wait for GitOps synchronization
3. Verify deployment health
4. Test application accessibility

**Test Playbook:** `tests/week8/test_deploy.yml` (already created)

**Success Criteria:**
- ✅ ArgoCD Application created
- ✅ GitOps sync successful
- ✅ Quarkus app deployed
- ✅ Application healthy

## Test Playbook Features

### test_deploy.yml (Already Created)

**Flexible Git Source:**
```yaml
# Default: Use Gitea (local)
git_repo_url: "https://gitea-with-admin-gitea.apps.cluster-4l957.4l957.sandbox1206.opentlc.com/opentlc-mgr/validated-patterns-ansible-toolkit.git"

# Override: Use GitHub (public)
export USE_GITHUB=true
git_repo_url: "https://github.com/tosin2013/validated-patterns-ansible-toolkit.git"
```

**Why This Matters:**
- **Default (Gitea):** Tests our local Git infrastructure (production-like)
- **Override (GitHub):** Allows testing without Gitea setup (development/CI)
- **Future-proof:** Other users can easily override to their own Git servers

**Usage:**
```bash
# Use Gitea (default)
ansible-playbook test_deploy.yml

# Use GitHub (override)
USE_GITHUB=true ansible-playbook test_deploy.yml
```

## Implementation Plan

### Step 1: Create test_gitea.yml

Create a test playbook that:
1. Verifies Gitea instance is running
2. Gets admin credentials from secret
3. Creates repository via Gitea API
4. Pushes code to repository
5. Verifies repository accessibility

### Step 2: Run Task 4 Test

```bash
cd tests/week8
ansible-playbook test_gitea.yml -vv | tee test_gitea_$(date +%Y%m%d_%H%M%S).log
```

### Step 3: Run Task 3 Test

```bash
cd tests/week8
ansible-playbook test_deploy.yml -vv | tee test_deploy_$(date +%Y%m%d_%H%M%S).log
```

## Alternative: Quick Test with GitHub

If you want to test Task 3 immediately without setting up Gitea:

```bash
cd tests/week8
USE_GITHUB=true ansible-playbook test_deploy.yml -vv
```

**Pros:**
- Immediate testing
- No Gitea setup required
- Validates ArgoCD functionality

**Cons:**
- Doesn't test local Git infrastructure
- Not production-like
- Skips Task 4 validation

## Recommendation

**Follow the proper order:**
1. ✅ Task 1: Prerequisites (Complete)
2. ✅ Task 2: Common (Complete)
3. 🔄 Task 4: Gitea (Do this next)
4. ⏳ Task 3: Deploy (Do after Task 4)
5. ⏳ Task 5: Secrets
6. ⏳ Task 6: Validate

This ensures:
- Complete infrastructure testing
- Production-like environment
- All dependencies validated
- Proper GitOps workflow

## Files Created

1. **tests/week8/test_deploy.yml** ✅
   - Flexible Git source (Gitea/GitHub)
   - ArgoCD Application deployment
   - GitOps sync verification
   - Health checks

2. **tests/week8/TASK_3_4_STRATEGY.md** ✅ (this file)
   - Strategy documentation
   - Task dependencies
   - Implementation plan

3. **tests/week8/test_gitea.yml** ⏳ (to be created)
   - Gitea repository setup
   - Code push automation
   - Repository verification

## Next Action

**Create and run test_gitea.yml to complete Task 4, then proceed with Task 3.**

---

**Updated:** 2025-10-25
**Status:** Task 3 blocked, Task 4 in progress
