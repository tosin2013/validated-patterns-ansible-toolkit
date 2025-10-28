# Week 9 Task 2: VP Operator Role Testing

## Overview

This directory contains comprehensive tests for the `validated_patterns_operator` role, which wraps the Validated Patterns Operator for simplified end-user deployment.

## Test Structure

```
tests/week9/
├── ansible.cfg                 # Ansible configuration for tests
├── inventory                   # Test inventory (localhost)
├── values-global.yaml          # Example global configuration
├── values-hub.yaml             # Example hub cluster configuration
├── test_operator.yml           # Main test playbook
├── run_tests.sh                # Test runner script
├── results/                    # Test results directory
│   └── operator_test_report.md # Generated test report
└── README.md                   # This file
```

## Prerequisites

### Required Tools

- **OpenShift CLI (`oc`)**: Must be installed and logged into cluster
- **Ansible**: Version 2.9+ with `kubernetes.core` collection
- **Cluster Access**: cluster-admin permissions required

### Installation

```bash
# Install Ansible
pip install ansible

# Install kubernetes.core collection
ansible-galaxy collection install kubernetes.core

# Login to OpenShift cluster
oc login <cluster-url>
```

## Test Suite

The test playbook (`test_operator.yml`) includes 8 comprehensive tests:

### Test 1: First Run (Operator Installation)
- Executes the `validated_patterns_operator` role
- Installs VP Operator
- Creates Pattern CR
- Deploys OpenShift GitOps
- Validates deployment

### Test 2: Operator Validation
- Verifies VP Operator CSV exists
- Checks operator phase is "Succeeded"
- Validates operator pod is running

### Test 3: Pattern CR Validation
- Verifies Pattern Custom Resource exists
- Checks Pattern CR configuration
- Validates Git URL and revision

### Test 4: GitOps Deployment Validation
- Verifies openshift-gitops namespace exists
- Checks ArgoCD instance is deployed
- Validates ArgoCD server pod is running

### Test 5: Clustergroup Application Validation
- Checks if clustergroup application exists
- Validates application health and sync status
- Records pending state if not yet created

### Test 6: Idempotency Test (Second Run)
- Re-executes the role
- Verifies no errors on second run
- Validates idempotent behavior

### Test 7: ArgoCD Applications Check
- Lists all ArgoCD applications
- Displays health and sync status
- Counts total applications

### Test 8: ArgoCD Access Information
- Verifies ArgoCD route exists
- Checks admin secret exists
- Displays access information

## Running Tests

### Quick Start

```bash
cd tests/week9
./run_tests.sh
```

### Manual Execution

```bash
cd tests/week9
ansible-playbook test_operator.yml -v
```

### With Extra Verbosity

```bash
ansible-playbook test_operator.yml -vvv
```

### Run Specific Tags

```bash
# Run only operator installation tests
ansible-playbook test_operator.yml --tags install

# Run only validation tests
ansible-playbook test_operator.yml --tags validate
```

## Test Results

### Test Report

After running tests, a comprehensive report is generated at:
```
tests/week9/results/operator_test_report.md
```

The report includes:
- Test environment details
- Individual test results
- Component status summary
- ArgoCD applications list
- Conclusion and next steps

### Expected Output

**Successful Test Run:**
```
✅ Pre-test validation: PASSED
✅ Test 1 (First run): PASSED
✅ Test 2 (Operator validation): PASSED
✅ Test 3 (Pattern CR validation): PASSED
✅ Test 4 (GitOps deployment): PASSED
✅ Test 5 (Clustergroup app): PASSED or PENDING
✅ Test 6 (Idempotency): PASSED
✅ Test 7 (Applications check): PASSED
✅ Test 8 (ArgoCD access): PASSED

First Run: PASSED
Second Run (Idempotency): PASSED
```

## Configuration

### Values Files

Edit the values files to match your pattern:

**values-global.yaml:**
```yaml
global:
  pattern: your-pattern-name
  targetRevision: main
  git:
    hostname: github.com
    account: your-account
```

**values-hub.yaml:**
```yaml
clusterGroup:
  name: hub
  isHubCluster: true
  applications:
    - name: your-app
      namespace: your-namespace
```

### Test Variables

Modify test variables in `test_operator.yml`:

```yaml
vars:
  test_pattern_name: "your-pattern"
  test_git_url: "https://github.com/your-org/your-pattern.git"
  test_git_revision: "main"
  vp_debug_mode: true  # Enable debug output
```

## Troubleshooting

### Test Failures

**Operator Installation Fails:**
```bash
# Check operator status
oc get csv -n openshift-operators | grep patterns

# Check operator logs
oc logs -n openshift-operators -l name=patterns-operator
```

**Pattern CR Not Created:**
```bash
# Check Pattern CR
oc get pattern -n openshift-operators

# Describe Pattern CR
oc describe pattern <pattern-name> -n openshift-operators
```

**GitOps Not Deploying:**
```bash
# Check GitOps operator
oc get csv -n openshift-gitops | grep gitops

# Check ArgoCD instance
oc get argocd -n openshift-gitops

# Check ArgoCD pods
oc get pods -n openshift-gitops
```

**Idempotency Test Fails:**
- Check if operator is already installed
- Verify Pattern CR already exists
- Review role logic for idempotency

### Common Issues

**Issue: kubernetes.core collection not found**
```bash
ansible-galaxy collection install kubernetes.core
```

**Issue: Not logged into cluster**
```bash
oc login <cluster-url>
```

**Issue: Insufficient permissions**
- Ensure you have cluster-admin role
- Check RBAC permissions

**Issue: Timeout waiting for components**
- Increase timeout values in role defaults
- Check cluster resources and performance
- Review operator logs for errors

## Validation Criteria

Tests are considered successful when:

1. ✅ VP Operator installs successfully
2. ✅ Pattern CR is created and processed
3. ✅ OpenShift GitOps is deployed
4. ✅ ArgoCD instance is running
5. ✅ Role demonstrates idempotency
6. ✅ All components are healthy

## Next Steps

After successful testing:

1. **Review Test Report**: Check `results/operator_test_report.md`
2. **Monitor ArgoCD**: Access ArgoCD UI to monitor applications
3. **Verify Applications**: Ensure all pattern applications are synced
4. **Proceed to Task 3**: End-to-end integration testing with all 7 roles

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Week 9 Tests

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test-operator-role:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Ansible
        run: pip install ansible

      - name: Install kubernetes.core
        run: ansible-galaxy collection install kubernetes.core

      - name: Run tests
        run: |
          cd tests/week9
          ./run_tests.sh

      - name: Upload test report
        uses: actions/upload-artifact@v3
        with:
          name: test-report
          path: tests/week9/results/operator_test_report.md
```

## References

- [Validated Patterns Documentation](https://validatedpatterns.io/)
- [Validated Patterns Operator](https://github.com/validatedpatterns/patterns-operator)
- [OpenShift GitOps](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

## Support

For issues or questions:
1. Review test output and logs
2. Check troubleshooting section above
3. Review role documentation: `ansible/roles/validated_patterns_operator/README.md`
4. Check Implementation Plan: `docs/IMPLEMENTATION-PLAN.md`
