# Week 10 Testing - Quick Start Guide

## Overview

Week 10 focuses on comprehensive testing of the Validated Patterns Toolkit with two main areas:
1. **Multi-Environment Testing** - Dev/prod overlay validation ✅ COMPLETE
2. **Security Validation** - RBAC, secrets, and network policies 🔄 IN PROGRESS

**Note:** Performance Testing (Task 2) has been skipped as it's not applicable for a reference application.

## Prerequisites

### Required Tools
```bash
# Verify tools are installed
oc version
ansible-playbook --version
kubectl version --client
curl --version
jq --version
```

### Cluster Access
```bash
# Login to OpenShift cluster
oc login <cluster-url> -u <username> -p <password>

# Verify access
oc whoami
oc cluster-info
```

### Environment Setup
```bash
# Navigate to test directory
cd tests/week10

# Verify directory structure
ls -la
```

## Task 1: Multi-Environment Testing (30 minutes)

### Quick Run
```bash
cd multi-environment
./run_multi_env_tests.sh
```

### Manual Testing
```bash
# Test dev overlay
ansible-playbook -i ../inventory test_dev_overlay.yml

# Test prod overlay
ansible-playbook -i ../inventory test_prod_overlay.yml

# View results
cat ../results/multi_environment_report.md
```

### What Gets Tested
- ✅ Dev overlay deployment (1 replica)
- ✅ Prod overlay deployment (3 replicas)
- ✅ Environment-specific configurations
- ✅ Resource limits and quotas
- ✅ Health endpoints
- ✅ Namespace isolation

### Expected Results
```
Total Tests: 2
Passed: 2
Failed: 0

✅ All multi-environment tests passed!
```

## Task 2: Performance Testing ❌ SKIPPED

**Status:** SKIPPED - Not applicable for reference application

**Rationale:**
- Reference application is for demonstration purposes only
- Performance varies greatly across different cluster configurations
- Not intended for production deployment
- Better to focus on security validation and documentation

**Decision:** Proceed directly to Task 3 (Security Validation)

## Task 3: Security Validation (30 minutes)

### Quick Run
```bash
cd security
./run_security_tests.sh
```

### Manual Testing
```bash
# RBAC validation
ansible-playbook -i ../inventory test_rbac.yml

# Secrets management
ansible-playbook -i ../inventory test_secrets.yml

# Network policies
ansible-playbook -i ../inventory test_network_policies.yml

# View results
cat ../results/security_report.md
```

### What Gets Tested
- ✅ ServiceAccount permissions
- ✅ Role and RoleBinding configuration
- ✅ Secret encryption and access control
- ✅ Network policy enforcement
- ✅ Pod security policies
- ✅ Least privilege verification

### Expected Results
```
Security Checks:
- RBAC: ✅ PASSED
- Secrets: ✅ PASSED
- Network Policies: ✅ PASSED
- Security Score: 100%

✅ All security tests passed!
```

## Complete Test Suite (2 hours)

### Run All Tests
```bash
# From tests/week10 directory
./run_all_tests.sh
```

This will execute:
1. Multi-environment tests (30 min)
2. Performance tests (45 min)
3. Security tests (30 min)
4. Generate comprehensive report (15 min)

### View All Results
```bash
# View combined report
cat results/week10_complete_report.md

# View individual reports
ls -la results/
cat results/multi_environment_report.md
cat results/performance_report.md
cat results/security_report.md
```

## Troubleshooting

### Test Failures

#### Cluster Access Issues
```bash
# Re-login to cluster
oc login <cluster-url>

# Verify permissions
oc auth can-i create deployments -n quarkus-dev
oc auth can-i create namespaces
```

#### Deployment Failures
```bash
# Check pod status
oc get pods -n quarkus-dev
oc get pods -n reference-app

# Check pod logs
oc logs -f deployment/dev-reference-app -n quarkus-dev
oc logs -f deployment/reference-app -n reference-app

# Check events
oc get events -n quarkus-dev --sort-by='.lastTimestamp'
```

#### Resource Issues
```bash
# Check node resources
oc adm top nodes

# Check pod resources
oc adm top pods -n quarkus-dev

# Check resource quotas
oc get resourcequota -n quarkus-dev
```

### Performance Issues

#### Slow Response Times
```bash
# Check application logs
oc logs -f deployment/reference-app -n reference-app

# Check resource usage
oc adm top pods -n reference-app

# Scale up if needed
oc scale deployment reference-app --replicas=5 -n reference-app
```

#### High Resource Usage
```bash
# Check resource limits
oc describe deployment reference-app -n reference-app

# Adjust resource limits if needed
oc set resources deployment reference-app \
  --limits=cpu=1000m,memory=512Mi \
  --requests=cpu=200m,memory=256Mi \
  -n reference-app
```

### Security Issues

#### RBAC Failures
```bash
# Check ServiceAccount
oc get sa reference-app -n reference-app

# Check Role and RoleBinding
oc get role,rolebinding -n reference-app

# Test permissions
oc auth can-i --list --as=system:serviceaccount:reference-app:reference-app
```

#### Secret Access Issues
```bash
# Check secrets
oc get secrets -n validated-patterns-secrets

# Verify secret data
oc get secret <secret-name> -n validated-patterns-secrets -o yaml

# Check secret permissions
oc auth can-i get secrets -n validated-patterns-secrets
```

## Cleanup

### Clean Up Test Deployments
```bash
# Delete dev deployment
oc delete namespace quarkus-dev

# Delete prod deployment
oc delete namespace reference-app

# Clean up test results
rm -rf results/*.md
```

### Preserve Results
```bash
# Archive results before cleanup
tar -czf week10-results-$(date +%Y%m%d).tar.gz results/

# Move archive to safe location
mv week10-results-*.tar.gz ~/backups/
```

## Next Steps

After completing Week 10 testing:

1. **Review Results**
   - Analyze all test reports
   - Identify any issues or improvements
   - Document lessons learned

2. **Update Documentation**
   - Update implementation plan
   - Mark Week 10 tasks as complete
   - Add any new findings to ADRs

3. **Proceed to Week 11**
   - Documentation & Polish
   - Comprehensive role documentation
   - Developer and end-user guides
   - Architecture diagrams

## Success Criteria

Week 10 is complete when:
- ✅ All multi-environment tests passing
- ✅ Performance benchmarks met
- ✅ Security validation passed
- ✅ All test reports generated
- ✅ Issues documented and resolved
- ✅ Implementation plan updated

## References

- [Week 10 README](README.md) - Detailed test documentation
- [Implementation Plan](../../docs/IMPLEMENTATION-PLAN.md) - Overall project plan
- [Quarkus Reference App](../../quarkus-reference-app/) - Test application
- [Validated Patterns](https://validatedpatterns.io/) - Framework documentation

---

**Quick Start Guide Version:** 1.0
**Last Updated:** 2025-10-27
**Status:** Active Testing
