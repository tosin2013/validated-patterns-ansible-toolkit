# Week 10: Multi-Environment Testing

**Phase 3 - Week 10 Testing Suite**

## Overview

This directory contains comprehensive tests for Week 10 of Phase 3, focusing on:
1. **Multi-Environment Testing** - Dev/prod overlay validation ✅ COMPLETE
2. **Performance Testing** - ❌ SKIPPED (Not applicable for reference app)
3. **Security Validation** - RBAC, secrets, and network policies 🔄 IN PROGRESS

## Test Structure

```
tests/week10/
├── README.md                           # This file
├── ansible.cfg                         # Ansible configuration
├── inventory                           # Test inventory
├── multi-environment/                  # Task 1: Multi-environment tests
│   ├── test_dev_overlay.yml           # Dev overlay testing
│   ├── test_prod_overlay.yml          # Prod overlay testing
│   ├── test_overlay_comparison.yml    # Compare dev vs prod
│   ├── test_edge_cases.yml            # Edge case testing
│   └── run_multi_env_tests.sh         # Test runner
├── performance/                        # Task 2: Performance tests
│   ├── test_load.yml                  # Load testing
│   ├── test_resource_usage.yml        # Resource utilization
│   ├── test_optimization.yml          # Performance optimization
│   └── run_performance_tests.sh       # Test runner
├── security/                           # Task 3: Security tests
│   ├── test_rbac.yml                  # RBAC validation
│   ├── test_secrets.yml               # Secrets management
│   ├── test_network_policies.yml      # Network policies
│   └── run_security_tests.sh          # Test runner
└── results/                            # Test results directory
    ├── multi_environment_report.md
    ├── performance_report.md
    └── security_report.md
```

## Prerequisites

### Required Tools
- OpenShift CLI (`oc`) - version 4.12+
- Ansible - version 2.9+
- kubectl - version 1.24+
- curl - for API testing
- jq - for JSON parsing

### Cluster Requirements
- OpenShift 4.12+ cluster
- Cluster admin access
- OpenShift GitOps operator installed
- Sufficient resources (6+ nodes recommended)

### Environment Setup
```bash
# Verify cluster access
oc whoami
oc cluster-info

# Verify GitOps operator
oc get csv -n openshift-gitops | grep gitops

# Set environment variables
export KUBECONFIG=/path/to/kubeconfig
export OC_USER=$(oc whoami)
```

## Task 1: Multi-Environment Testing

**Objective:** Validate dev/prod overlay configurations and test different cluster topologies

### Test Scenarios

#### 1. Dev Overlay Testing
- Deploy Quarkus app with dev overlay
- Verify 1 replica deployment
- Test dev-specific configurations
- Validate resource limits (dev profile)
- Test namespace isolation

#### 2. Prod Overlay Testing
- Deploy Quarkus app with prod overlay
- Verify 3 replica deployment
- Test prod-specific configurations
- Validate resource limits (prod profile)
- Test high availability

#### 3. Overlay Comparison
- Compare dev vs prod configurations
- Validate environment-specific settings
- Test configuration drift detection
- Verify kustomize patches

#### 4. Edge Case Testing
- Test with missing resources
- Test with invalid configurations
- Test rollback scenarios
- Test upgrade paths

### Running Tests

```bash
cd tests/week10/multi-environment

# Run all multi-environment tests
./run_multi_env_tests.sh

# Run individual tests
ansible-playbook test_dev_overlay.yml
ansible-playbook test_prod_overlay.yml
ansible-playbook test_overlay_comparison.yml
ansible-playbook test_edge_cases.yml
```

### Expected Results
- ✅ Dev overlay deploys successfully (1 replica)
- ✅ Prod overlay deploys successfully (3 replicas)
- ✅ Environment-specific configs applied correctly
- ✅ Edge cases handled gracefully
- ✅ Test report generated

## Task 2: Performance Testing ❌ SKIPPED

**Status:** SKIPPED - Not applicable for reference application
**Rationale:** The Quarkus reference application is for demonstration purposes only and not intended for production deployment. Performance testing would not provide meaningful value as:
- Performance varies greatly across different cluster configurations
- Reference app is not production-bound
- Better to focus resources on security validation and documentation

**Decision:** Skip Task 2 and proceed directly to Task 3 (Security Validation)

### Test Scenarios

#### 1. Load Testing
- Baseline performance metrics
- Concurrent request testing (100, 500, 1000 requests)
- Response time analysis
- Throughput measurement
- Error rate monitoring

#### 2. Resource Utilization
- CPU usage monitoring
- Memory consumption analysis
- Network I/O metrics
- Storage utilization
- Pod resource limits validation

#### 3. Performance Optimization
- Identify bottlenecks
- Test optimization strategies
- Validate improvements
- Document recommendations

### Running Tests

```bash
cd tests/week10/performance

# Run all performance tests
./run_performance_tests.sh

# Run individual tests
ansible-playbook test_load.yml
ansible-playbook test_resource_usage.yml
ansible-playbook test_optimization.yml
```

### Expected Results
- ✅ Baseline metrics established
- ✅ Load testing completed (< 200ms p95 latency)
- ✅ Resource usage within limits
- ✅ Optimization recommendations documented
- ✅ Performance report generated

## Task 3: Security Validation

**Objective:** RBAC verification, secrets management, and network policies testing

### Test Scenarios

#### 1. RBAC Validation
- ServiceAccount permissions
- Role and RoleBinding verification
- ClusterRole validation
- Permission boundary testing
- Least privilege verification

#### 2. Secrets Management
- Secret creation and encryption
- Secret rotation testing
- Sealed secrets validation
- Secret access control
- Secret cleanup verification

#### 3. Network Policies
- Pod-to-pod communication
- Ingress/egress rules
- Network isolation testing
- Service mesh integration
- DNS policy validation

### Running Tests

```bash
cd tests/week10/security

# Run all security tests
./run_security_tests.sh

# Run individual tests
ansible-playbook test_rbac.yml
ansible-playbook test_secrets.yml
ansible-playbook test_network_policies.yml
```

### Expected Results
- ✅ RBAC configured correctly
- ✅ Secrets encrypted and managed properly
- ✅ Network policies enforced
- ✅ Security audit passed
- ✅ Security report generated

## Test Reports

All test results are saved to `tests/week10/results/`:

- **multi_environment_report.md** - Multi-environment test results
- **performance_report.md** - Performance test results and metrics
- **security_report.md** - Security validation results

## Success Criteria

### Week 10 Overall
- ✅ All multi-environment tests passing
- ✅ Performance benchmarks met
- ✅ Security validation passed
- ✅ All test reports generated
- ✅ Documentation complete

### Specific Metrics
- **Deployment Success Rate:** 100%
- **Test Coverage:** > 90%
- **Performance:** < 200ms p95 latency
- **Resource Efficiency:** < 80% utilization
- **Security Score:** 100% (all checks passing)

## Troubleshooting

### Common Issues

#### Test Failures
```bash
# Check cluster status
oc get nodes
oc get pods --all-namespaces

# Check test logs
cat tests/week10/results/*.log
```

#### Performance Issues
```bash
# Check resource usage
oc adm top nodes
oc adm top pods -n quarkus-dev

# Check application logs
oc logs -f deployment/reference-app -n quarkus-dev
```

#### Security Issues
```bash
# Check RBAC
oc auth can-i --list --as=system:serviceaccount:quarkus-dev:reference-app

# Check secrets
oc get secrets -n validated-patterns-secrets

# Check network policies
oc get networkpolicies -n quarkus-dev
```

## Next Steps

After completing Week 10 testing:
1. Review all test reports
2. Address any identified issues
3. Document lessons learned
4. Proceed to Week 11: Documentation & Polish

## References

- [OpenShift Documentation](https://docs.openshift.com/)
- [Kustomize Documentation](https://kustomize.io/)
- [Validated Patterns Framework](https://validatedpatterns.io/)
- [Quarkus Performance Guide](https://quarkus.io/guides/performance-measure)
