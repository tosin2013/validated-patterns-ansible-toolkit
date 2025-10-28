# Week 9 Testing - Quick Start Guide

## 🚀 Run Tests in 3 Steps

### Step 1: Prerequisites

```bash
# Ensure you're logged into OpenShift
oc login <your-cluster-url>

# Verify cluster access
oc whoami
oc cluster-info
```

### Step 2: Navigate to Test Directory

```bash
cd tests/week9
```

### Step 3: Run Tests

```bash
./run_tests.sh
```

That's it! The script will:
- ✅ Check prerequisites (oc, ansible, cluster login)
- ✅ Verify values files exist
- ✅ Run comprehensive test suite (8 tests)
- ✅ Generate test report
- ✅ Display results

## 📊 Expected Output

```
========================================
Week 9 Task 2: VP Operator Role Testing
========================================

Checking prerequisites...
✅ OpenShift CLI available and logged in
✅ Ansible available
✅ kubernetes.core collection available
✅ Values files found

========================================
Running Test Playbook
========================================

[Test execution output...]

========================================
✅ Tests Completed Successfully
========================================

Test report saved to: results/operator_test_report.md
```

## 🔍 What Gets Tested

1. **Operator Installation** - VP Operator deployed to cluster
2. **Pattern CR Creation** - Pattern Custom Resource created
3. **GitOps Deployment** - OpenShift GitOps (ArgoCD) deployed
4. **Component Validation** - All components healthy
5. **Idempotency** - Role can run multiple times safely
6. **Applications** - ArgoCD applications created
7. **Access Info** - ArgoCD UI access information

## 📝 View Test Report

```bash
cat results/operator_test_report.md
```

## 🐛 Troubleshooting

### Test Fails: Not logged into cluster
```bash
oc login <cluster-url>
```

### Test Fails: kubernetes.core not found
```bash
ansible-galaxy collection install kubernetes.core
```

### Test Fails: Operator installation timeout
- Check cluster resources: `oc get nodes`
- Check operator logs: `oc logs -n openshift-operators -l name=patterns-operator`
- Increase timeout in role defaults

### View Detailed Logs
```bash
ansible-playbook test_operator.yml -vvv
```

## 🎯 Next Steps After Testing

1. **Review Test Report**: `results/operator_test_report.md`
2. **Access ArgoCD UI**: Get URL from test output
3. **Monitor Applications**: Check ArgoCD for app sync status
4. **Proceed to Task 3**: End-to-end integration testing

## 📚 More Information

- Full documentation: `README.md`
- Role documentation: `../../ansible/roles/validated_patterns_operator/README.md`
- Implementation plan: `../../docs/IMPLEMENTATION-PLAN.md`
