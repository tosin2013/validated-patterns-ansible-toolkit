# Integration Testing - Quick Start Guide

## 🚀 Run Integration Tests in 3 Steps

### Step 1: Login to Cluster

```bash
oc login <your-cluster-url>
```

### Step 2: Navigate to Integration Test Directory

```bash
cd tests/integration
```

### Step 3: Run Integration Tests

```bash
./run_integration_tests.sh
```

That's it! The script will handle everything automatically.

---

## 📊 What Gets Tested

The integration test validates the complete end-user workflow:

1. **VP Operator Installation** - Validated Patterns Operator deployed
2. **Pattern CR Creation** - Pattern Custom Resource created
3. **GitOps Deployment** - OpenShift GitOps (ArgoCD) deployed
4. **Component Validation** - All components healthy
5. **Application Deployment** - ArgoCD applications created
6. **Performance Metrics** - Deployment timing and resource usage

---

## 🧹 Cleanup Before Testing

If you have an existing deployment, run cleanup first:

```bash
cd cleanup
./cleanup.sh
cd ..
```

Or let the test runner detect and offer cleanup automatically.

---

## 📝 View Test Report

```bash
cat results/end_to_end_report.md
```

---

## 🎯 Expected Results

**Successful Test:**
```
✅ Phase 0 (Pre-test validation): PASSED
✅ Phase 1 (VP Operator deployment): PASSED - 180s
✅ Phase 2 (Operator validation): PASSED
✅ Phase 3 (Pattern CR validation): PASSED
✅ Phase 4 (GitOps deployment): PASSED
✅ Phase 5 (ArgoCD applications): PASSED
✅ Phase 6 (Performance metrics): PASSED
✅ Phase 7 (Report generation): PASSED

Total Duration: 240s
```

---

## 🐛 Troubleshooting

### Existing Deployment Detected

```bash
cd cleanup
./cleanup.sh
```

### Operator Installation Timeout

```bash
# Check operator logs
oc logs -n openshift-operators -l name=patterns-operator

# Check operator status
oc get csv -n openshift-operators | grep patterns
```

### GitOps Not Deploying

```bash
# Check GitOps pods
oc get pods -n openshift-gitops

# Check ArgoCD instance
oc get argocd -n openshift-gitops
```

### Pattern CR Issues

```bash
# Describe Pattern CR
oc describe pattern validated-patterns-ansible-toolkit -n openshift-operators

# Check operator logs
oc logs -n openshift-operators -l name=patterns-operator
```

---

## 🔗 Access ArgoCD

After successful deployment:

```bash
# Get ArgoCD URL
oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}'

# Get admin password
oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d
```

---

## 📚 More Information

- Full documentation: `README.md`
- Cleanup guide: `cleanup/README.md`
- Role documentation: `../../ansible/roles/validated_patterns_operator/README.md`
- Implementation plan: `../../docs/IMPLEMENTATION-PLAN.md`

---

## ⏱️ Expected Duration

- **Pre-test validation:** < 10 seconds
- **VP Operator deployment:** 180-360 seconds
- **Validation phases:** 30-60 seconds
- **Total test time:** 4-7 minutes

---

## 🎓 For Developers

This integration test validates the **end-user workflow** using the `validated_patterns_operator` role.

**Development workflow** (using individual roles 1-2, 4-7) is tested separately in Week 8 tests.

**Both workflows produce identical results!**
