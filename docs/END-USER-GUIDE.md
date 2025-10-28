# End-User Guide - Validated Patterns Toolkit

**Audience:** Pattern consumers who want to deploy existing patterns quickly
**Workflow:** VP Operator (Role 3)
**Version:** 1.0
**Last Updated:** 2025-10-27

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Configuration](#configuration)
6. [Deployment](#deployment)
7. [Monitoring](#monitoring)
8. [Troubleshooting](#troubleshooting)
9. [Examples](#examples)

---

## Overview

### What is the End-User Workflow?

The end-user workflow uses the **Validated Patterns Operator** to provide a simplified deployment experience. This workflow is designed for:

- **Pattern Consumers:** Deploying existing validated patterns
- **Production Deployments:** Quick, reliable pattern deployment
- **Minimal Configuration:** Just edit values files and deploy
- **Operator-Managed:** Let the operator handle complexity

### VP Operator Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    End-User Workflow                         │
│                  (1 Role - Simplified)                       │
└─────────────────────────────────────────────────────────────┘

Step 1: Edit values-*.yaml files
  ↓

Step 2: Run ansible-playbook
  ↓

VP Operator Handles Everything:
  ├─ Installs OpenShift GitOps
  ├─ Creates Pattern CR
  ├─ Deploys Clustergroup Application
  ├─ Syncs all applications
  └─ Validates deployment
```

### When to Use End-User Workflow

✅ **Use End-User Workflow When:**
- Deploying an existing validated pattern
- Production deployment without customization
- Quick pattern evaluation
- Minimal configuration required
- Operator-managed lifecycle preferred

❌ **Don't Use End-User Workflow When:**
- Developing a new pattern (use [Developer Guide](DEVELOPER-GUIDE.md))
- Requiring granular control over deployment
- Testing pattern changes locally
- Debugging pattern internals

---

## Quick Start

### 5-Minute Deployment

```bash
# 1. Login to OpenShift
oc login <cluster-url>

# 2. Clone repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# 3. Edit configuration
vi quarkus-reference-app/values-global.yaml
vi quarkus-reference-app/values-hub.yaml

# 4. Deploy pattern
ansible-playbook ansible/playbooks/deploy_with_operator.yml \
  -e validated_patterns_pattern_name=quarkus-reference-app \
  -e validated_patterns_git_url=https://github.com/tosin2013/validated-patterns-ansible-toolkit.git

# 5. Monitor deployment
oc get applications -n openshift-gitops -w
```

That's it! The VP Operator handles everything else.

---

## Prerequisites

### Required Access

```bash
# OpenShift cluster access
oc login <cluster-url> -u <username> -p <password>

# Verify cluster-admin permissions (required for operator installation)
oc auth can-i create subscriptions -n openshift-operators
# yes

oc auth can-i create operatorgroups -n openshift-operators
# yes
```

### Required Tools

```bash
# OpenShift CLI
oc version
# Client Version: 4.12+

# Ansible (for running playbooks)
ansible --version
# ansible [core 2.15+]

# Git (for cloning patterns)
git --version
# git version 2.30+
```

### Cluster Requirements

- **OpenShift Version:** 4.12 or higher
- **Cluster Size:** Minimum 3 nodes
- **Resources:** 8 CPU cores, 16GB RAM minimum
- **Storage:** Default storage class configured
- **Network:** Internet access for pulling images

### Verify Prerequisites

```bash
# Check OpenShift version
oc version

# Check cluster nodes
oc get nodes

# Check storage classes
oc get storageclass

# Check operator hub access
oc get packagemanifests -n openshift-marketplace | grep patterns
```

---

## Installation

### Step 1: Install Ansible Collections

```bash
# Install required collections
ansible-galaxy collection install -r files/requirements.yml

# Verify installation
ansible-galaxy collection list | grep kubernetes
```

### Step 2: Clone Pattern Repository

```bash
# Clone the pattern you want to deploy
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# Or clone a different pattern
git clone https://github.com/validatedpatterns/<pattern-name>.git
cd <pattern-name>
```

### Step 3: Verify Cluster Access

```bash
# Login to OpenShift
oc login <cluster-url>

# Verify access
oc whoami
oc cluster-info

# Check permissions
oc auth can-i create subscriptions -n openshift-operators
```

---

## Configuration

### Understanding Values Files

Validated Patterns use three main configuration files:

1. **values-global.yaml** - Global pattern configuration
2. **values-hub.yaml** - Hub cluster configuration
3. **values-secrets.yaml** - Secrets configuration (optional)

### Editing values-global.yaml

```yaml
# quarkus-reference-app/values-global.yaml
global:
  # Pattern name (must match repository)
  pattern: quarkus-reference-app

  # Git configuration
  targetRevision: main

  # Optional: Custom domain
  domain: apps.example.com

  # Optional: Additional options
  options:
    useCSV: false
    syncPolicy: Automatic
    installPlanApproval: Automatic
```

**Key Fields:**
- `pattern`: Name of your pattern (must match directory name)
- `targetRevision`: Git branch/tag to deploy (usually `main`)
- `domain`: Custom domain for routes (optional)

### Editing values-hub.yaml

```yaml
# quarkus-reference-app/values-hub.yaml
clusterGroup:
  # Cluster group name
  name: hub

  # Mark as hub cluster
  isHubCluster: true

  # Namespaces to create
  namespaces:
    - reference-app
    - validated-patterns-secrets

  # Applications to deploy
  applications:
    - name: reference-app
      namespace: reference-app
      project: default
      path: quarkus-reference-app/k8s/overlays/prod

  # Subscriptions (operators)
  subscriptions:
    # Add any required operators here

  # Projects (ArgoCD AppProjects)
  projects:
    - default
```

**Key Fields:**
- `name`: Cluster group name (usually `hub`)
- `isHubCluster`: Set to `true` for hub cluster
- `namespaces`: List of namespaces to create
- `applications`: List of applications to deploy
- `subscriptions`: List of operators to install

### Editing values-secrets.yaml (Optional)

```yaml
# quarkus-reference-app/values-secrets.yaml.template
secrets:
  # Example: Database credentials
  - name: database-credentials
    namespace: reference-app
    data:
      username: admin
      password: changeme

  # Example: API keys
  - name: api-keys
    namespace: reference-app
    data:
      api-key: your-api-key-here
```

**Important:**
- Copy `values-secrets.yaml.template` to `values-secrets.yaml`
- Never commit `values-secrets.yaml` to Git
- Use Sealed Secrets or External Secrets Operator for production

### Configuration Examples

#### Minimal Configuration

```yaml
# values-global.yaml
global:
  pattern: my-pattern
  targetRevision: main

# values-hub.yaml
clusterGroup:
  name: hub
  isHubCluster: true
  namespaces:
    - my-app
  applications:
    - name: my-app
      namespace: my-app
      path: k8s/base
```

#### Production Configuration

```yaml
# values-global.yaml
global:
  pattern: my-pattern
  targetRevision: v1.0.0
  domain: apps.prod.example.com
  options:
    useCSV: true
    syncPolicy: Manual
    installPlanApproval: Manual

# values-hub.yaml
clusterGroup:
  name: production
  isHubCluster: true
  namespaces:
    - my-app-prod
    - my-app-monitoring
  applications:
    - name: my-app
      namespace: my-app-prod
      path: k8s/overlays/prod
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
  subscriptions:
    - name: openshift-pipelines-operator
      namespace: openshift-operators
```

---

## Deployment

### Method 1: Using Ansible Playbook (Recommended)

#### Create Deployment Playbook

Create `deploy.yml`:

```yaml
---
- name: Deploy Pattern using VP Operator
  hosts: localhost
  connection: local
  gather_facts: no

  vars:
    # Pattern configuration
    validated_patterns_pattern_name: "quarkus-reference-app"
    validated_patterns_git_url: "https://github.com/tosin2013/validated-patterns-ansible-toolkit.git"
    validated_patterns_git_revision: "main"

    # Operator configuration
    vp_operator_channel: "stable"
    vp_operator_install_plan_approval: "Automatic"

    # Validation
    vp_validate_deployment: true
    vp_validate_gitops: true
    vp_validate_clustergroup: true

  roles:
    - validated_patterns_operator
```

#### Run Deployment

```bash
# Deploy pattern
ansible-playbook deploy.yml

# With custom variables
ansible-playbook deploy.yml \
  -e validated_patterns_pattern_name=my-pattern \
  -e validated_patterns_git_url=https://github.com/myorg/my-pattern.git

# With debug output
ansible-playbook deploy.yml -vv
```

### Method 2: Using Ansible Navigator

```bash
# Deploy with ansible-navigator
ansible-navigator run deploy.yml

# With execution environment
ansible-navigator run deploy.yml \
  --execution-environment-image quay.io/ansible/creator-ee:latest
```

### Method 3: Manual Operator Installation

If you prefer manual installation:

```bash
# 1. Create operator subscription
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: patterns-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: patterns-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
EOF

# 2. Wait for operator to be ready
oc wait --for=condition=Ready csv \
  -l operators.coreos.com/patterns-operator.openshift-operators \
  -n openshift-operators \
  --timeout=300s

# 3. Create Pattern CR
cat <<EOF | oc apply -f -
apiVersion: gitops.hybrid-cloud-patterns.io/v1alpha1
kind: Pattern
metadata:
  name: quarkus-reference-app
  namespace: openshift-operators
spec:
  clusterGroupName: hub
  gitSpec:
    targetRevision: main
    repoURL: https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
EOF
```

### Deployment Timeline

**Expected deployment time:** 10-15 minutes

```
0:00 - Operator installation starts
2:00 - Operator ready
3:00 - Pattern CR created
4:00 - OpenShift GitOps deployed
6:00 - ArgoCD ready
7:00 - Clustergroup application created
10:00 - Applications syncing
15:00 - All applications healthy
```

---

## Monitoring

### Check Operator Status

```bash
# Check operator installation
oc get csv -n openshift-operators | grep patterns

# Check operator pod
oc get pods -n openshift-operators -l name=patterns-operator

# Check operator logs
oc logs -n openshift-operators -l name=patterns-operator --tail=50
```

### Check Pattern CR Status

```bash
# List Pattern CRs
oc get pattern -n openshift-operators

# Describe Pattern CR
oc describe pattern quarkus-reference-app -n openshift-operators

# Check Pattern status
oc get pattern quarkus-reference-app -n openshift-operators -o jsonpath='{.status}'
```

### Check GitOps Deployment

```bash
# Check GitOps operator
oc get csv -n openshift-gitops | grep gitops

# Check ArgoCD instance
oc get argocd -n openshift-gitops

# Check ArgoCD pods
oc get pods -n openshift-gitops

# Check ArgoCD applications
oc get applications -n openshift-gitops

# Watch application sync
oc get applications -n openshift-gitops -w
```

### Access ArgoCD UI

```bash
# Get ArgoCD URL
ARGOCD_URL=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
echo "ArgoCD UI: https://$ARGOCD_URL"

# Get admin password
ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d)
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"

# Open in browser
open "https://$ARGOCD_URL"
```

### Check Application Status

```bash
# Check application namespace
oc get all -n reference-app

# Check application pods
oc get pods -n reference-app

# Check application logs
oc logs -n reference-app -l app=reference-app --tail=50

# Check application route
oc get route -n reference-app

# Test application
APP_URL=$(oc get route reference-app -n reference-app -o jsonpath='{.spec.host}')
curl https://$APP_URL/hello
```

### Monitoring Dashboard

Create a monitoring script `monitor.sh`:

```bash
#!/bin/bash

echo "=== Validated Patterns Deployment Status ==="
echo ""

echo "1. Operator Status:"
oc get csv -n openshift-operators | grep patterns
echo ""

echo "2. Pattern CR Status:"
oc get pattern -n openshift-operators
echo ""

echo "3. GitOps Status:"
oc get pods -n openshift-gitops
echo ""

echo "4. Applications Status:"
oc get applications -n openshift-gitops
echo ""

echo "5. Application Pods:"
oc get pods -n reference-app
echo ""

echo "6. Application Routes:"
oc get routes -n reference-app
echo ""
```

Run monitoring:

```bash
chmod +x monitor.sh
./monitor.sh

# Or watch continuously
watch -n 10 ./monitor.sh
```

---

## Troubleshooting

### Common Issues

#### 1. Operator Installation Fails

**Symptoms:**
- Operator CSV not appearing
- Operator pod not starting

**Solutions:**

```bash
# Check operator subscription
oc get subscription patterns-operator -n openshift-operators

# Check install plan
oc get installplan -n openshift-operators

# Check operator logs
oc logs -n openshift-operators -l name=patterns-operator

# Manual approval if needed
INSTALL_PLAN=$(oc get installplan -n openshift-operators -o jsonpath='{.items[0].metadata.name}')
oc patch installplan $INSTALL_PLAN -n openshift-operators \
  --type merge -p '{"spec":{"approved":true}}'
```

#### 2. Pattern CR Not Processing

**Symptoms:**
- Pattern CR created but nothing happens
- No GitOps deployment

**Solutions:**

```bash
# Check Pattern CR status
oc describe pattern <pattern-name> -n openshift-operators

# Check operator logs
oc logs -n openshift-operators -l name=patterns-operator --tail=100

# Delete and recreate Pattern CR
oc delete pattern <pattern-name> -n openshift-operators
oc apply -f pattern.yaml
```

#### 3. GitOps Not Deploying

**Symptoms:**
- ArgoCD not installed
- No applications appearing

**Solutions:**

```bash
# Check GitOps subscription
oc get subscription openshift-gitops-operator -n openshift-operators

# Check ArgoCD instance
oc get argocd -n openshift-gitops

# Check ArgoCD logs
oc logs -n openshift-gitops -l app.kubernetes.io/name=openshift-gitops-server

# Restart ArgoCD
oc delete pod -n openshift-gitops -l app.kubernetes.io/name=openshift-gitops-server
```

#### 4. Applications Not Syncing

**Symptoms:**
- Applications stuck in "OutOfSync" state
- Applications not deploying

**Solutions:**

```bash
# Check application status
oc get application <app-name> -n openshift-gitops -o yaml

# Manual sync
oc patch application <app-name> -n openshift-gitops \
  --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'

# Check application logs in ArgoCD UI
# Or use CLI
argocd app get <app-name> --refresh
```

#### 5. Permission Errors

**Symptoms:**
- "Forbidden" errors
- RBAC errors

**Solutions:**

```bash
# Check current user
oc whoami

# Check permissions
oc auth can-i create subscriptions -n openshift-operators
oc auth can-i create patterns -n openshift-operators

# Login as cluster-admin
oc login -u system:admin

# Or request cluster-admin access from your administrator
```

### Debug Mode

Enable debug mode in your playbook:

```yaml
---
- name: Deploy with debug
  hosts: localhost
  vars:
    vp_debug_mode: true
    ansible_verbosity: 2
  roles:
    - validated_patterns_operator
```

### Getting Help

1. **Check Operator Logs:**
   ```bash
   oc logs -n openshift-operators -l name=patterns-operator --tail=100 -f
   ```

2. **Check ArgoCD Logs:**
   ```bash
   oc logs -n openshift-gitops -l app.kubernetes.io/name=openshift-gitops-server --tail=100 -f
   ```

3. **Check Events:**
   ```bash
   oc get events -n openshift-operators --sort-by='.lastTimestamp'
   oc get events -n openshift-gitops --sort-by='.lastTimestamp'
   ```

4. **Community Support:**
   - GitHub Issues: https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues
   - Red Hat Validated Patterns: https://validatedpatterns.io
   - OpenShift GitOps: https://docs.openshift.com/gitops/

---

## Examples

### Example 1: Deploy Quarkus Reference App

```bash
# 1. Clone repository
git clone https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
cd validated-patterns-ansible-toolkit

# 2. Review configuration
cat quarkus-reference-app/values-global.yaml
cat quarkus-reference-app/values-hub.yaml

# 3. Deploy
ansible-playbook ansible/playbooks/deploy_with_operator.yml \
  -e validated_patterns_pattern_name=quarkus-reference-app \
  -e validated_patterns_git_url=https://github.com/tosin2013/validated-patterns-ansible-toolkit.git

# 4. Monitor
oc get applications -n openshift-gitops -w

# 5. Access application
APP_URL=$(oc get route reference-app -n reference-app -o jsonpath='{.spec.host}')
curl https://$APP_URL/hello
```

### Example 2: Deploy Custom Pattern

```bash
# 1. Clone your pattern
git clone https://github.com/myorg/my-pattern.git
cd my-pattern

# 2. Edit configuration
vi values-global.yaml
vi values-hub.yaml

# 3. Create deployment playbook
cat > deploy.yml <<EOF
---
- name: Deploy My Pattern
  hosts: localhost
  connection: local
  gather_facts: no
  vars:
    validated_patterns_pattern_name: "my-pattern"
    validated_patterns_git_url: "https://github.com/myorg/my-pattern.git"
    validated_patterns_git_revision: "main"
  roles:
    - validated_patterns_operator
EOF

# 4. Deploy
ansible-playbook deploy.yml

# 5. Monitor
oc get applications -n openshift-gitops -w
```

### Example 3: Deploy with Custom Domain

```yaml
# values-global.yaml
global:
  pattern: my-pattern
  targetRevision: main
  domain: apps.custom.example.com

# deploy.yml
---
- name: Deploy with custom domain
  hosts: localhost
  vars:
    validated_patterns_pattern_name: "my-pattern"
    validated_patterns_git_url: "https://github.com/myorg/my-pattern.git"
    validated_patterns_custom_domain: "apps.custom.example.com"
  roles:
    - validated_patterns_operator
```

---

## Next Steps

1. **Explore Advanced Features** - Read the [Developer Guide](DEVELOPER-GUIDE.md) for more control
2. **Customize Your Pattern** - Modify values files for your needs
3. **Add Applications** - Extend your pattern with additional applications
4. **Set Up CI/CD** - Automate pattern deployment with Tekton pipelines
5. **Join Community** - Contribute to Validated Patterns

---

## Additional Resources

- **Validated Patterns Documentation:** https://validatedpatterns.io
- **OpenShift GitOps:** https://docs.openshift.com/gitops/
- **Ansible Documentation:** https://docs.ansible.com
- **Pattern Examples:** https://github.com/validatedpatterns

---

**Document Version:** 1.0
**Last Updated:** 2025-10-27
**Maintained By:** Validated Patterns Toolkit Development Team
