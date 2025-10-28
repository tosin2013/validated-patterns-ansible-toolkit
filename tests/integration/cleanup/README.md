# Cleanup Utilities

## Overview

This directory contains utilities for cleaning up Validated Patterns deployments before running integration tests.

## Files

- **`cleanup.sh`** - Automated cleanup script (recommended)
- **`cleanup_deployment.yml`** - Ansible cleanup playbook (advanced)

## Quick Cleanup

### Automated Script (Recommended)

```bash
cd cleanup
./cleanup.sh
```

The script will:
1. Display current resources
2. Confirm cleanup operation
3. Delete ArgoCD applications
4. Delete Pattern Custom Resource
5. Delete application namespaces
6. Optionally delete GitOps namespace
7. Optionally uninstall VP Operator

### Ansible Playbook (Advanced)

```bash
ansible-playbook cleanup_deployment.yml
```

## What Gets Cleaned Up

### Always Cleaned

1. **ArgoCD Applications** - All applications in openshift-gitops namespace
2. **Pattern CR** - Pattern Custom Resource
3. **Application Namespaces**:
   - validated-patterns
   - quarkus-app-dev
   - quarkus-app-prod

### Optional (User Prompted)

4. **GitOps Namespace** - openshift-gitops (removes ArgoCD completely)
5. **VP Operator** - Validated Patterns Operator (uninstalls operator)

## Usage Examples

### Full Cleanup (Interactive)

```bash
./cleanup.sh
```

Follow the prompts to:
- Confirm cleanup
- Choose whether to delete GitOps namespace
- Choose whether to uninstall VP Operator

### Quick Cleanup (Keep Operator)

```bash
# Delete applications and Pattern CR only
oc delete applications --all -n openshift-gitops
oc delete pattern validated-patterns-ansible-toolkit -n openshift-operators
oc delete namespace validated-patterns quarkus-app-dev quarkus-app-prod
```

### Complete Cleanup (Remove Everything)

When prompted by `cleanup.sh`:
- Confirm cleanup: `yes`
- Delete GitOps namespace: `yes`
- Uninstall VP Operator: `yes`

## Verification

### Check Remaining Resources

```bash
# Check Pattern CRs
oc get pattern -n openshift-operators

# Check ArgoCD applications
oc get applications -n openshift-gitops

# Check application namespaces
oc get namespace | grep -E "validated-patterns|quarkus-app"

# Check VP Operator
oc get csv -n openshift-operators | grep patterns
```

### Expected Clean State

After cleanup:
```
Pattern CRs: None
ArgoCD Applications: None (or only system apps if GitOps retained)
Application Namespaces: None
VP Operator: None (if uninstalled) or Installed (if retained)
```

## Troubleshooting

### Namespace Stuck in Terminating

**Problem:** Namespace won't delete

**Solution:**
```bash
# Check for finalizers
oc get namespace <namespace> -o yaml | grep finalizers

# Remove finalizers if needed (advanced)
oc patch namespace <namespace> -p '{"metadata":{"finalizers":[]}}' --type=merge
```

### Pattern CR Won't Delete

**Problem:** Pattern CR stuck in deletion

**Solution:**
```bash
# Check finalizers
oc get pattern validated-patterns-ansible-toolkit -n openshift-operators -o yaml | grep finalizers

# Force delete if needed
oc patch pattern validated-patterns-ansible-toolkit -n openshift-operators -p '{"metadata":{"finalizers":[]}}' --type=merge
```

### ArgoCD Applications Won't Delete

**Problem:** Applications stuck in deletion

**Solution:**
```bash
# Check application status
oc get applications -n openshift-gitops

# Force delete if needed
oc delete applications --all -n openshift-gitops --force --grace-period=0
```

## Safety Features

### Confirmation Prompts

The cleanup script requires explicit confirmation:
- Initial cleanup confirmation
- GitOps namespace deletion
- VP Operator uninstallation

### Wait Timeouts

Cleanup operations have 5-minute timeouts to prevent hanging.

### Error Handling

All operations use `ignore_errors: yes` to continue cleanup even if resources don't exist.

## When to Run Cleanup

### Before Integration Tests

Always run cleanup before integration tests to ensure a clean state:
```bash
cd tests/integration/cleanup
./cleanup.sh
cd ..
./run_integration_tests.sh
```

### After Failed Tests

If tests fail, cleanup before retrying:
```bash
cd cleanup
./cleanup.sh
```

### Between Test Runs

For multiple test runs, cleanup between each run:
```bash
# Run test
./run_integration_tests.sh

# Cleanup
cd cleanup
./cleanup.sh
cd ..

# Run test again
./run_integration_tests.sh
```

## Manual Cleanup Commands

### Delete Pattern CR

```bash
oc delete pattern validated-patterns-ansible-toolkit -n openshift-operators --wait=true
```

### Delete ArgoCD Applications

```bash
oc delete applications --all -n openshift-gitops --wait=true
```

### Delete Application Namespaces

```bash
oc delete namespace validated-patterns --wait=false
oc delete namespace quarkus-app-dev --wait=false
oc delete namespace quarkus-app-prod --wait=false
```

### Delete GitOps Namespace

```bash
oc delete namespace openshift-gitops --wait=false
```

### Uninstall VP Operator

```bash
# Delete subscription
oc delete subscription patterns-operator -n openshift-operators

# Delete CSV
CSV_NAME=$(oc get csv -n openshift-operators | grep patterns-operator | awk '{print $1}')
oc delete csv $CSV_NAME -n openshift-operators
```

## Cleanup Playbook Variables

### Configuration

Edit `cleanup_deployment.yml` to customize:

```yaml
vars:
  cleanup_pattern_name: "validated-patterns-ansible-toolkit"
  cleanup_operator_namespace: "openshift-operators"
  cleanup_gitops_namespace: "openshift-gitops"
  cleanup_app_namespaces:
    - validated-patterns
    - quarkus-app-dev
    - quarkus-app-prod
  cleanup_confirm: true  # Set to false for non-interactive
  cleanup_wait_timeout: 300  # 5 minutes
```

### Non-Interactive Mode

For CI/CD, disable confirmations:

```yaml
vars:
  cleanup_confirm: false
```

## Best Practices

1. **Always cleanup before tests** - Ensures clean state
2. **Keep operator installed** - Faster subsequent tests
3. **Delete GitOps only when needed** - Saves time
4. **Verify cleanup completed** - Check remaining resources
5. **Wait for namespace deletion** - Don't rush to next test

## References

- [Integration Test README](../README.md)
- [Implementation Plan](../../../docs/IMPLEMENTATION-PLAN.md)
- [OpenShift Documentation](https://docs.openshift.com/)
