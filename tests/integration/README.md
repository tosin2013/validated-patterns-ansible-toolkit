# End-to-End Integration Testing

## Overview

This directory contains comprehensive end-to-end integration tests for the Validated Patterns Toolkit. These tests validate the complete end-user workflow using the `validated_patterns_operator` role.

## Directory Structure

```
tests/integration/
├── ansible.cfg                          # Ansible configuration
├── inventory                            # Test inventory
├── values-global.yaml                   # Global pattern configuration
├── values-hub.yaml                      # Hub cluster configuration
├── run_integration_tests.sh             # Main test runner
├── cleanup/                             # Cleanup utilities
│   ├── cleanup_deployment.yml           # Ansible cleanup playbook
│   └── cleanup.sh                       # Automated cleanup script
├── playbooks/                           # Test playbooks
│   └── test_end_to_end.yml              # End-to-end integration test
├── results/                             # Test results
│   └── end_to_end_report.md             # Generated test report
└── README.md                            # This file
```

## Prerequisites

### Required Tools

- **OpenShift CLI (`oc`)**: Logged into cluster with cluster-admin permissions
- **Ansible**: Version 2.9+ with `kubernetes.core` collection
- **Clean Cluster**: No existing Validated Patterns deployment (or run cleanup first)

### Installation

```bash
# Install Ansible
pip install ansible

# Install kubernetes.core collection
ansible-galaxy collection install kubernetes.core

# Login to OpenShift cluster
oc login <cluster-url>
```

## Quick Start

### Step 1: Navigate to Integration Test Directory

```bash
cd tests/integration
```

### Step 2: Run Integration Tests

```bash
./run_integration_tests.sh
```

The script will:
- ✅ Check prerequisites
- ✅ Detect existing deployments
- ✅ Offer to run cleanup if needed
- ✅ Execute end-to-end integration test
- ✅ Generate comprehensive test report
- ✅ Display ArgoCD access information

## Test Workflow

### End-to-End Integration Test

The integration test validates the complete end-user workflow:

**Phase 0: Pre-Test Validation**
- Verify cluster connectivity
- Check values files exist
- Detect existing deployments

**Phase 1: VP Operator Deployment**
- Execute `validated_patterns_operator` role
- Install VP Operator
- Create Pattern CR
- Deploy OpenShift GitOps
- Create clustergroup application

**Phase 2: Operator Validation**
- Verify VP Operator CSV exists
- Check operator phase is "Succeeded"
- Validate operator pod is running

**Phase 3: Pattern CR Validation**
- Verify Pattern CR exists
- Check Pattern CR configuration
- Validate Git URL and revision

**Phase 4: GitOps Deployment Validation**
- Verify openshift-gitops namespace
- Check ArgoCD instance deployed
- Validate ArgoCD server running

**Phase 5: ArgoCD Applications Validation**
- List all ArgoCD applications
- Check for clustergroup application
- Display health and sync status

**Phase 6: Performance Metrics**
- Calculate deployment duration
- Collect resource usage
- Generate performance report

**Phase 7: Report Generation**
- Create comprehensive test report
- Document all component status
- Provide troubleshooting guidance

## Cleanup

### Before Running Tests

It's recommended to start with a clean cluster. Run cleanup if you have an existing deployment:

```bash
cd cleanup
./cleanup.sh
```

The cleanup script will:
1. Delete ArgoCD applications
2. Delete Pattern Custom Resource
3. Delete application namespaces
4. Optionally delete GitOps namespace
5. Optionally uninstall VP Operator

### Automated Cleanup

The integration test runner will detect existing deployments and offer to run cleanup automatically.

### Manual Cleanup

```bash
# Delete Pattern CR
oc delete pattern validated-patterns-ansible-toolkit -n openshift-operators

# Delete ArgoCD applications
oc delete applications --all -n openshift-gitops

# Delete application namespaces
oc delete namespace validated-patterns quarkus-app-dev quarkus-app-prod
```

## Test Results

### Test Report

After running tests, a comprehensive report is generated at:
```
tests/integration/results/end_to_end_report.md
```

The report includes:
- Test environment details
- Phase-by-phase results
- Performance metrics
- Component status
- ArgoCD access information
- Troubleshooting guidance
- Next steps

### Expected Output

**Successful Test Run:**
```
✅ Phase 0 (Pre-test validation): PASSED
✅ Phase 1 (VP Operator deployment): PASSED - 180s
✅ Phase 2 (Operator validation): PASSED
✅ Phase 3 (Pattern CR validation): PASSED
✅ Phase 4 (GitOps deployment): PASSED
✅ Phase 5 (ArgoCD applications): PASSED - 3 applications
✅ Phase 6 (Performance metrics): PASSED
✅ Phase 7 (Report generation): PASSED

Total Duration: 240s
Deployment Duration: 180s
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

## Troubleshooting

### Test Fails: Existing Deployment

**Problem:** Pattern CR already exists

**Solution:**
```bash
cd cleanup
./cleanup.sh
```

### Test Fails: Operator Installation Timeout

**Problem:** VP Operator takes too long to install

**Solution:**
1. Check cluster resources: `oc get nodes`
2. Check operator logs: `oc logs -n openshift-operators -l name=patterns-operator`
3. Increase timeout in role defaults

### Test Fails: GitOps Not Deploying

**Problem:** OpenShift GitOps not deploying

**Solution:**
1. Check GitOps operator: `oc get csv -n openshift-gitops | grep gitops`
2. Check ArgoCD instance: `oc get argocd -n openshift-gitops`
3. Check ArgoCD pods: `oc get pods -n openshift-gitops`

### Test Fails: Pattern CR Not Processing

**Problem:** Pattern CR stuck in pending state

**Solution:**
1. Check Pattern CR: `oc describe pattern validated-patterns-ansible-toolkit -n openshift-operators`
2. Check operator logs: `oc logs -n openshift-operators -l name=patterns-operator`
3. Verify Git URL is accessible

## Performance Benchmarks

### Expected Timings

Based on typical OpenShift clusters:

- **Operator Installation:** 60-120 seconds
- **Pattern CR Processing:** 30-60 seconds
- **GitOps Deployment:** 90-180 seconds
- **Total Deployment:** 180-360 seconds

### Factors Affecting Performance

- Cluster size and resources
- Network connectivity
- Image pull times
- Number of applications
- Application complexity

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Integration Tests

on:
  push:
    branches: [main]
  pull_request:

jobs:
  integration-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Ansible
        run: pip install ansible

      - name: Install kubernetes.core
        run: ansible-galaxy collection install kubernetes.core

      - name: Run integration tests
        run: |
          cd tests/integration
          ./run_integration_tests.sh

      - name: Upload test report
        uses: actions/upload-artifact@v3
        with:
          name: integration-test-report
          path: tests/integration/results/end_to_end_report.md
```

## Developer Reference

### Test Playbook Structure

The integration test playbook (`playbooks/test_end_to_end.yml`) is structured as:

1. **Variables Section** - Test configuration and tracking
2. **Pre-Test Validation** - Prerequisites and cluster checks
3. **Deployment Phase** - Execute VP Operator role
4. **Validation Phases** - Verify all components
5. **Performance Metrics** - Collect timing and resource data
6. **Report Generation** - Create comprehensive report

### Adding Custom Tests

To add custom validation:

1. Add a new phase block in `test_end_to_end.yml`
2. Use `block/rescue` for error handling
3. Record results in `test_results` list
4. Update `test_phases` with timing data

Example:
```yaml
- name: Phase X - Custom validation
  block:
    - name: Your validation tasks
      # ... your tasks ...

    - name: Record success
      set_fact:
        test_results: "{{ test_results + ['✅ Phase X: PASSED'] }}"

  rescue:
    - name: Record failure
      set_fact:
        test_results: "{{ test_results + ['❌ Phase X: FAILED'] }}"
```

## References

- [Validated Patterns Documentation](https://validatedpatterns.io/)
- [Implementation Plan](../../docs/IMPLEMENTATION-PLAN.md)
- [VP Operator Role README](../../ansible/roles/validated_patterns_operator/README.md)
- [Week 9 Tests](../week9/README.md)

## Support

For issues or questions:
1. Review test output and report
2. Check troubleshooting section above
3. Review cleanup procedures
4. Check Implementation Plan for context
