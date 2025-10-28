# Comprehensive Troubleshooting Guide - Validated Patterns Toolkit

**Version:** 1.0
**Last Updated:** 2025-10-27

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites Issues](#prerequisites-issues)
3. [Common Infrastructure Issues](#common-infrastructure-issues)
4. [Pattern Deployment Issues](#pattern-deployment-issues)
5. [GitOps and ArgoCD Issues](#gitops-and-argocd-issues)
6. [Secrets Management Issues](#secrets-management-issues)
7. [Operator Issues](#operator-issues)
8. [Network and Connectivity Issues](#network-and-connectivity-issues)
9. [Debug Techniques](#debug-techniques)
10. [Log Analysis](#log-analysis)
11. [Support Resources](#support-resources)

---

## Overview

This comprehensive troubleshooting guide covers common issues encountered when deploying Validated Patterns, organized by category with detailed solutions and debug techniques.

### Quick Troubleshooting Checklist

Before diving into specific issues, check these common problems:

```bash
# 1. Check cluster access
oc whoami
oc cluster-info

# 2. Check OpenShift version
oc version

# 3. Check node status
oc get nodes

# 4. Check operator status
oc get csv -A | grep -E "gitops|patterns"

# 5. Check ArgoCD status
oc get pods -n openshift-gitops

# 6. Check application status
oc get applications -n openshift-gitops

# 7. Check recent events
oc get events -A --sort-by='.lastTimestamp' | tail -20
```

---

## Prerequisites Issues

### Issue 1: OpenShift Version Too Old

**Symptom:**
```
FAILED! => {"msg": "OpenShift version 4.11 is below minimum 4.12"}
```

**Cause:** Cluster is running OpenShift version older than 4.12

**Solutions:**

1. **Upgrade OpenShift cluster** (recommended):
   ```bash
   # Check current version
   oc version

   # Check available updates
   oc adm upgrade

   # Upgrade to 4.12+
   oc adm upgrade --to=4.12.x
   ```

2. **Override minimum version** (testing only, not recommended):
   ```yaml
   vars:
     validated_patterns_min_openshift_version: "4.11"
   ```

**Prevention:**
- Always check cluster version before deployment
- Plan cluster upgrades in advance
- Test patterns on supported versions

---

### Issue 2: Insufficient Cluster Resources

**Symptom:**
```
FAILED! => {"msg": "Cluster has only 2 nodes, minimum 3 required"}
```

**Cause:** Cluster doesn't meet minimum resource requirements

**Solutions:**

1. **Add more nodes** (recommended):
   ```bash
   # Check current nodes
   oc get nodes

   # Add nodes via your cloud provider or infrastructure
   # AWS example:
   # aws ec2 run-instances --instance-type m5.xlarge ...
   ```

2. **Override minimum requirements** (testing only):
   ```yaml
   vars:
     validated_patterns_min_nodes: 2
     validated_patterns_min_cpu: 4
     validated_patterns_min_memory: 8
   ```

**Debug:**
```bash
# Check node resources
oc describe nodes | grep -E "cpu|memory"

# Check resource allocation
oc adm top nodes
```

**Prevention:**
- Size cluster appropriately before deployment
- Monitor resource usage
- Plan for growth

---

### Issue 3: Required Operator Not Found

**Symptom:**
```
FAILED! => {"msg": "Required operator not found: openshift-gitops-operator"}
```

**Cause:** OpenShift GitOps operator is not installed

**Solutions:**

1. **Install via OperatorHub** (recommended):
   ```bash
   cat <<EOF | oc apply -f -
   apiVersion: operators.coreos.com/v1alpha1
   kind: Subscription
   metadata:
     name: openshift-gitops-operator
     namespace: openshift-operators
   spec:
     channel: stable
     name: openshift-gitops-operator
     source: redhat-operators
     sourceNamespace: openshift-marketplace
     installPlanApproval: Automatic
   EOF

   # Wait for operator to be ready
   oc wait --for=condition=Ready csv \
     -l operators.coreos.com/openshift-gitops-operator.openshift-operators \
     -n openshift-operators \
     --timeout=300s
   ```

2. **Check operator status**:
   ```bash
   # List all operators
   oc get csv -A

   # Check GitOps operator specifically
   oc get csv -n openshift-operators | grep gitops

   # Check operator pod
   oc get pods -n openshift-operators | grep gitops
   ```

**Debug:**
```bash
# Check subscription
oc get subscription openshift-gitops-operator -n openshift-operators

# Check install plan
oc get installplan -n openshift-operators

# Check operator logs
oc logs -n openshift-operators -l name=openshift-gitops-operator
```

**Prevention:**
- Install required operators before running patterns
- Use prerequisites role to validate
- Document operator dependencies

---

### Issue 4: RBAC Permission Denied

**Symptom:**
```
FAILED! => {"msg": "User does not have cluster-admin permissions"}
Error from server (Forbidden): ...
```

**Cause:** Current user lacks necessary permissions

**Solutions:**

1. **Login as cluster-admin**:
   ```bash
   # Login with admin credentials
   oc login -u system:admin

   # Or use kubeconfig with admin access
   export KUBECONFIG=/path/to/admin/kubeconfig
   ```

2. **Grant cluster-admin to user**:
   ```bash
   # Grant cluster-admin role
   oc adm policy add-cluster-role-to-user cluster-admin <username>

   # Verify permissions
   oc auth can-i create subscriptions -n openshift-operators
   ```

**Debug:**
```bash
# Check current user
oc whoami

# Check user permissions
oc auth can-i --list

# Check specific permissions
oc auth can-i create subscriptions -n openshift-operators
oc auth can-i create patterns -n openshift-operators
oc auth can-i create applications -n openshift-gitops
```

**Prevention:**
- Ensure proper credentials before deployment
- Document required permissions
- Use service accounts for automation

---

### Issue 5: No Default Storage Class

**Symptom:**
```
FAILED! => {"msg": "No default storage class found"}
```

**Cause:** Cluster has no default storage class configured

**Solutions:**

1. **Set default storage class**:
   ```bash
   # List storage classes
   oc get storageclass

   # Set default
   oc patch storageclass <storage-class-name> \
     -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

   # Verify
   oc get storageclass | grep default
   ```

2. **Remove default from other classes** (if multiple defaults):
   ```bash
   # Remove default annotation
   oc patch storageclass <old-default> \
     -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
   ```

**Debug:**
```bash
# Check storage classes
oc get storageclass

# Check storage class details
oc describe storageclass <name>

# Test PVC creation
cat <<EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Check PVC status
oc get pvc test-pvc

# Cleanup
oc delete pvc test-pvc
```

**Prevention:**
- Configure default storage class during cluster setup
- Document storage requirements
- Test storage before pattern deployment

---

## Common Infrastructure Issues

### Issue 6: Helm Repository Not Configured

**Symptom:**
```
FAILED! => {"msg": "Helm repository not configured"}
Error: repo not found
```

**Cause:** Validated Patterns Helm repository is not added

**Solutions:**

1. **Add Helm repository**:
   ```bash
   # Add repository
   helm repo add validated-patterns https://validatedpatterns.io/charts

   # Update repository cache
   helm repo update

   # Verify
   helm repo list
   helm search repo validated-patterns
   ```

2. **Check Helm version**:
   ```bash
   # Must be v3.12+
   helm version

   # Upgrade if needed
   # Download from https://github.com/helm/helm/releases
   ```

**Debug:**
```bash
# List repositories
helm repo list

# Search for charts
helm search repo clustergroup

# Check repository URL
helm repo list -o yaml
```

**Prevention:**
- Install Helm v3.12+ before deployment
- Add repositories in prerequisites
- Document Helm requirements

---

### Issue 7: clustergroup-chart Deployment Fails

**Symptom:**
```
FAILED! => {"msg": "Failed to deploy clustergroup-chart"}
Error: chart not found
```

**Cause:** Chart version not available or incompatible

**Solutions:**

1. **Check chart availability**:
   ```bash
   # Search for chart
   helm search repo clustergroup --versions

   # Install specific version
   helm install clustergroup validated-patterns/clustergroup-chart \
     --version 0.9.* \
     --namespace openshift-gitops
   ```

2. **Verify multisource support**:
   ```bash
   # Must use 0.9.* for multisource
   helm show chart validated-patterns/clustergroup-chart --version 0.9.*
   ```

**Debug:**
```bash
# Check Helm releases
helm list -A

# Check release status
helm status clustergroup -n openshift-gitops

# Check release history
helm history clustergroup -n openshift-gitops

# Get release values
helm get values clustergroup -n openshift-gitops
```

**Prevention:**
- Use correct chart version (0.9.*)
- Test chart deployment before production
- Document chart dependencies

---

### Issue 8: rhvp.cluster_utils Collection Not Found

**Symptom:**
```
FAILED! => {"msg": "Collection rhvp.cluster_utils not found"}
```

**Cause:** Ansible collection is not installed

**Solutions:**

1. **Install collection**:
   ```bash
   # Install from requirements file
   ansible-galaxy collection install -r files/requirements.yml

   # Or install directly
   ansible-galaxy collection install rhvp.cluster_utils:1.0.0

   # Verify installation
   ansible-galaxy collection list | grep rhvp
   ```

2. **Check collection path**:
   ```bash
   # Show collection paths
   ansible-config dump | grep COLLECTIONS_PATHS

   # List installed collections
   ansible-galaxy collection list
   ```

**Debug:**
```bash
# Verify collection installation
ls -la ~/.ansible/collections/ansible_collections/rhvp/

# Check collection version
ansible-galaxy collection list rhvp.cluster_utils

# Test collection import
ansible -m debug -a "msg={{ lookup('rhvp.cluster_utils.version') }}"
```

**Prevention:**
- Install collections before running roles
- Use requirements.yml for dependencies
- Document collection requirements

---

## Pattern Deployment Issues

### Issue 9: ArgoCD Application Not Syncing

**Symptom:**
```
Application stuck in "OutOfSync" state
Application health: "Progressing" for extended time
```

**Cause:** Various issues with Git repository, manifests, or ArgoCD configuration

**Solutions:**

1. **Manual sync**:
   ```bash
   # Sync application
   oc patch application <app-name> -n openshift-gitops \
     --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'

   # Or use ArgoCD CLI
   argocd app sync <app-name>
   ```

2. **Check application status**:
   ```bash
   # Get application details
   oc get application <app-name> -n openshift-gitops -o yaml

   # Check sync status
   oc get application <app-name> -n openshift-gitops \
     -o jsonpath='{.status.sync.status}'

   # Check health status
   oc get application <app-name> -n openshift-gitops \
     -o jsonpath='{.status.health.status}'
   ```

3. **Check Git repository access**:
   ```bash
   # Test Git access
   git ls-remote <repo-url>

   # Check repository credentials (if private)
   oc get secret -n openshift-gitops | grep repo
   ```

4. **Check manifest errors**:
   ```bash
   # Get application conditions
   oc get application <app-name> -n openshift-gitops \
     -o jsonpath='{.status.conditions}'

   # Check ArgoCD logs
   oc logs -n openshift-gitops -l app.kubernetes.io/name=openshift-gitops-application-controller
   ```

**Debug:**
```bash
# Access ArgoCD UI
ARGOCD_URL=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
echo "ArgoCD UI: https://$ARGOCD_URL"

# Get admin password
ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops \
  -o jsonpath='{.data.admin\.password}' | base64 -d)
echo "Password: $ARGOCD_PASSWORD"

# Check application in UI for detailed errors
```

**Prevention:**
- Validate manifests before deployment
- Test Git repository access
- Use proper sync policies
- Monitor application health

---

### Issue 10: Pattern Namespace Not Created

**Symptom:**
```
Error: namespace "my-app" not found
Pods not starting due to missing namespace
```

**Cause:** Namespace not created before deploying resources

**Solutions:**

1. **Create namespace manually**:
   ```bash
   # Create namespace
   oc create namespace my-app

   # Or use YAML
   cat <<EOF | oc apply -f -
   apiVersion: v1
   kind: Namespace
   metadata:
     name: my-app
   EOF
   ```

2. **Check values-hub.yaml**:
   ```yaml
   # Ensure namespace is listed
   clusterGroup:
     namespaces:
       - my-app
   ```

3. **Verify namespace creation**:
   ```bash
   # List namespaces
   oc get namespaces

   # Check namespace details
   oc describe namespace my-app
   ```

**Debug:**
```bash
# Check namespace events
oc get events -n my-app --sort-by='.lastTimestamp'

# Check namespace labels
oc get namespace my-app -o yaml

# Check namespace quotas
oc get resourcequota -n my-app
```

**Prevention:**
- Define namespaces in values-hub.yaml
- Create namespaces before deploying applications
- Use namespace creation in patterns

---

## GitOps and ArgoCD Issues

### Issue 11: ArgoCD Not Installed

**Symptom:**
```
Error: ArgoCD instance not found in openshift-gitops
No route found for openshift-gitops-server
```

**Cause:** OpenShift GitOps operator installed but ArgoCD instance not created

**Solutions:**

1. **Check ArgoCD instance**:
   ```bash
   # List ArgoCD instances
   oc get argocd -A

   # Check openshift-gitops namespace
   oc get argocd -n openshift-gitops
   ```

2. **Wait for ArgoCD creation** (automatic after operator install):
   ```bash
   # Wait for ArgoCD instance
   oc wait --for=condition=Ready argocd/openshift-gitops \
     -n openshift-gitops \
     --timeout=300s

   # Check ArgoCD pods
   oc get pods -n openshift-gitops
   ```

3. **Create ArgoCD instance manually** (if needed):
   ```bash
   cat <<EOF | oc apply -f -
   apiVersion: argoproj.io/v1alpha1
   kind: ArgoCD
   metadata:
     name: openshift-gitops
     namespace: openshift-gitops
   spec:
     server:
       route:
         enabled: true
   EOF
   ```

**Debug:**
```bash
# Check GitOps operator
oc get csv -n openshift-operators | grep gitops

# Check operator logs
oc logs -n openshift-operators -l name=openshift-gitops-operator

# Check ArgoCD events
oc get events -n openshift-gitops --sort-by='.lastTimestamp'
```

**Prevention:**
- Wait for operator to fully install
- Verify ArgoCD instance creation
- Check operator logs for errors

---

### Issue 12: ArgoCD Application CRD Not Found

**Symptom:**
```
Error: the server doesn't have a resource type "applications"
no matches for kind "Application" in version "argoproj.io/v1alpha1"
```

**Cause:** ArgoCD CRDs not installed

**Solutions:**

1. **Check CRDs**:
   ```bash
   # List ArgoCD CRDs
   oc get crd | grep argoproj

   # Should see:
   # applications.argoproj.io
   # appprojects.argoproj.io
   # argocds.argoproj.io
   ```

2. **Reinstall GitOps operator** (if CRDs missing):
   ```bash
   # Delete subscription
   oc delete subscription openshift-gitops-operator -n openshift-operators

   # Wait for cleanup
   sleep 30

   # Reinstall
   cat <<EOF | oc apply -f -
   apiVersion: operators.coreos.com/v1alpha1
   kind: Subscription
   metadata:
     name: openshift-gitops-operator
     namespace: openshift-operators
   spec:
     channel: stable
     name: openshift-gitops-operator
     source: redhat-operators
     sourceNamespace: openshift-marketplace
   EOF
   ```

**Debug:**
```bash
# Check CRD details
oc get crd applications.argoproj.io -o yaml

# Check CRD version
oc get crd applications.argoproj.io \
  -o jsonpath='{.spec.versions[*].name}'
```

**Prevention:**
- Verify CRDs after operator installation
- Don't manually delete CRDs
- Use supported operator versions

---

## Secrets Management Issues

### Issue 13: Secrets Namespace Not Created

**Symptom:**
```
Error: namespace "validated-patterns-secrets" not found
Secret creation fails
```

**Cause:** Dedicated secrets namespace not created

**Solutions:**

1. **Create secrets namespace**:
   ```bash
   # Create namespace
   oc create namespace validated-patterns-secrets

   # Add labels
   oc label namespace validated-patterns-secrets \
     app.kubernetes.io/name=validated-patterns-secrets
   ```

2. **Run secrets role**:
   ```yaml
   - hosts: localhost
     roles:
       - validated_patterns_secrets
   ```

**Debug:**
```bash
# Check namespace
oc get namespace validated-patterns-secrets

# Check secrets in namespace
oc get secrets -n validated-patterns-secrets

# Check RBAC
oc get rolebinding -n validated-patterns-secrets
```

**Prevention:**
- Create secrets namespace before deploying patterns
- Use validated_patterns_secrets role
- Document secrets requirements

---

### Issue 14: Sealed Secrets Operator Not Working

**Symptom:**
```
Error: SealedSecret CRD not found
Sealed secrets not being decrypted
```

**Cause:** Sealed Secrets operator not installed or not working

**Solutions:**

1. **Install Sealed Secrets operator**:
   ```bash
   # Install via OperatorHub or Helm
   helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
   helm install sealed-secrets sealed-secrets/sealed-secrets \
     -n kube-system
   ```

2. **Check operator status**:
   ```bash
   # Check controller pod
   oc get pods -n kube-system | grep sealed-secrets

   # Check CRD
   oc get crd sealedsecrets.bitnami.com
   ```

3. **Test sealed secret**:
   ```bash
   # Create test secret
   echo -n "test" | oc create secret generic test-secret \
     --dry-run=client --from-file=password=/dev/stdin -o yaml | \
     kubeseal -o yaml > sealed-secret.yaml

   # Apply sealed secret
   oc apply -f sealed-secret.yaml

   # Check if decrypted
   oc get secret test-secret
   ```

**Debug:**
```bash
# Check controller logs
oc logs -n kube-system -l name=sealed-secrets-controller

# Check sealed secret status
oc get sealedsecret <name> -o yaml

# Check events
oc get events -n <namespace> | grep SealedSecret
```

**Prevention:**
- Install Sealed Secrets operator before using
- Test encryption/decryption
- Document sealed secrets workflow

---

## Operator Issues

### Issue 15: VP Operator Installation Fails

**Symptom:**
```
Error: operator installation failed
CSV not appearing
Operator pod not starting
```

**Cause:** Various operator installation issues

**Solutions:**

1. **Check operator subscription**:
   ```bash
   # Check subscription
   oc get subscription patterns-operator -n openshift-operators

   # Check install plan
   oc get installplan -n openshift-operators

   # Manual approval if needed
   INSTALL_PLAN=$(oc get installplan -n openshift-operators \
     -o jsonpath='{.items[0].metadata.name}')
   oc patch installplan $INSTALL_PLAN -n openshift-operators \
     --type merge -p '{"spec":{"approved":true}}'
   ```

2. **Check CSV status**:
   ```bash
   # List CSVs
   oc get csv -n openshift-operators

   # Check specific CSV
   oc get csv -n openshift-operators | grep patterns

   # Describe CSV for errors
   oc describe csv <csv-name> -n openshift-operators
   ```

3. **Check operator pod**:
   ```bash
   # Check pod status
   oc get pods -n openshift-operators | grep patterns

   # Check pod logs
   oc logs -n openshift-operators -l name=patterns-operator
   ```

**Debug:**
```bash
# Check operator events
oc get events -n openshift-operators --sort-by='.lastTimestamp'

# Check operator deployment
oc get deployment -n openshift-operators | grep patterns

# Check operator service account
oc get sa -n openshift-operators | grep patterns
```

**Prevention:**
- Verify OperatorHub access
- Check cluster connectivity
- Use supported operator versions
- Monitor operator installation

---

### Issue 16: Pattern CR Not Processing

**Symptom:**
```
Pattern CR created but nothing happens
No GitOps deployment
Operator not reconciling
```

**Cause:** Operator not processing Pattern CR

**Solutions:**

1. **Check Pattern CR status**:
   ```bash
   # Get Pattern CR
   oc get pattern -n openshift-operators

   # Describe Pattern CR
   oc describe pattern <pattern-name> -n openshift-operators

   # Check status
   oc get pattern <pattern-name> -n openshift-operators -o yaml
   ```

2. **Check operator logs**:
   ```bash
   # Get operator logs
   oc logs -n openshift-operators -l name=patterns-operator --tail=100

   # Follow logs
   oc logs -n openshift-operators -l name=patterns-operator -f
   ```

3. **Delete and recreate Pattern CR**:
   ```bash
   # Delete Pattern CR
   oc delete pattern <pattern-name> -n openshift-operators

   # Recreate
   oc apply -f pattern.yaml
   ```

**Debug:**
```bash
# Check operator reconciliation
oc logs -n openshift-operators -l name=patterns-operator | grep reconcile

# Check Pattern CR events
oc get events -n openshift-operators | grep Pattern

# Check operator metrics
oc port-forward -n openshift-operators \
  $(oc get pod -n openshift-operators -l name=patterns-operator -o name) \
  8080:8080
curl localhost:8080/metrics
```

**Prevention:**
- Validate Pattern CR before applying
- Monitor operator logs
- Use correct CR schema
- Test in development first

---

## Network and Connectivity Issues

### Issue 17: Cannot Pull Images

**Symptom:**
```
Error: ImagePullBackOff
Error: ErrImagePull
Failed to pull image
```

**Cause:** Cannot access image registry

**Solutions:**

1. **Check image pull secrets**:
   ```bash
   # List pull secrets
   oc get secrets -n <namespace> | grep pull

   # Check default pull secret
   oc get secret pull-secret -n openshift-config
   ```

2. **Test image pull**:
   ```bash
   # Try pulling image manually
   podman pull <image-url>

   # Or use oc
   oc run test --image=<image-url> --restart=Never
   oc logs test
   oc delete pod test
   ```

3. **Add image pull secret** (if needed):
   ```bash
   # Create pull secret
   oc create secret docker-registry my-pull-secret \
     --docker-server=<registry> \
     --docker-username=<username> \
     --docker-password=<password> \
     -n <namespace>

   # Link to service account
   oc secrets link default my-pull-secret --for=pull -n <namespace>
   ```

**Debug:**
```bash
# Check pod events
oc describe pod <pod-name> -n <namespace>

# Check image URL
oc get pod <pod-name> -n <namespace> \
  -o jsonpath='{.spec.containers[*].image}'

# Test registry connectivity
curl -I https://<registry-url>
```

**Prevention:**
- Configure pull secrets before deployment
- Use accessible registries
- Test image pulls
- Document registry requirements

---

### Issue 18: DNS Resolution Failures

**Symptom:**
```
Error: dial tcp: lookup <hostname>: no such host
Cannot resolve DNS names
```

**Cause:** DNS configuration issues

**Solutions:**

1. **Check DNS pods**:
   ```bash
   # Check DNS pods
   oc get pods -n openshift-dns

   # Check DNS operator
   oc get clusteroperator dns
   ```

2. **Test DNS resolution**:
   ```bash
   # Create test pod
   oc run test-dns --image=busybox --restart=Never -- sleep 3600

   # Test DNS
   oc exec test-dns -- nslookup kubernetes.default
   oc exec test-dns -- nslookup google.com

   # Cleanup
   oc delete pod test-dns
   ```

3. **Check DNS configuration**:
   ```bash
   # Check DNS operator config
   oc get dns.operator cluster -o yaml

   # Check DNS service
   oc get svc -n openshift-dns
   ```

**Debug:**
```bash
# Check DNS logs
oc logs -n openshift-dns -l dns.operator.openshift.io/daemonset-dns=default

# Check CoreDNS config
oc get configmap dns-default -n openshift-dns -o yaml

# Check node DNS
oc debug node/<node-name>
chroot /host
cat /etc/resolv.conf
```

**Prevention:**
- Verify DNS during cluster setup
- Monitor DNS operator health
- Test DNS resolution regularly
- Document DNS requirements

---

## Debug Techniques

### Enable Ansible Debug Mode

```yaml
---
- name: Debug playbook
  hosts: localhost
  vars:
    ansible_verbosity: 2
  roles:
    - validated_patterns_prerequisites
```

Run with verbose output:
```bash
ansible-playbook playbook.yml -vv
```

### Enable Kubernetes Debug Logging

```bash
# Set log level for specific components
oc set env deployment/<deployment-name> LOG_LEVEL=debug

# Check logs
oc logs <pod-name> --tail=100 -f
```

### Use oc debug

```bash
# Debug node
oc debug node/<node-name>

# Debug pod
oc debug pod/<pod-name>

# Debug deployment
oc debug deployment/<deployment-name>
```

### Capture Cluster Information

```bash
# Gather cluster info
oc adm must-gather

# Specific component
oc adm must-gather --image=<component-image>

# Extract and analyze
tar -xzf must-gather.tar.gz
cd must-gather.*
```

---

## Log Analysis

### ArgoCD Logs

```bash
# Application controller
oc logs -n openshift-gitops \
  -l app.kubernetes.io/name=openshift-gitops-application-controller \
  --tail=100

# Server
oc logs -n openshift-gitops \
  -l app.kubernetes.io/name=openshift-gitops-server \
  --tail=100

# Repo server
oc logs -n openshift-gitops \
  -l app.kubernetes.io/name=openshift-gitops-repo-server \
  --tail=100
```

### Operator Logs

```bash
# GitOps operator
oc logs -n openshift-operators \
  -l name=openshift-gitops-operator \
  --tail=100

# Patterns operator
oc logs -n openshift-operators \
  -l name=patterns-operator \
  --tail=100
```

### Application Logs

```bash
# Application pods
oc logs -n <namespace> -l app=<app-name> --tail=100

# All containers in pod
oc logs <pod-name> -n <namespace> --all-containers=true

# Previous container (if crashed)
oc logs <pod-name> -n <namespace> --previous
```

---

## Support Resources

### Documentation

- **[Developer Guide](DEVELOPER-GUIDE.md)** - Development workflow
- **[End-User Guide](END-USER-GUIDE.md)** - Deployment workflow
- **[Ansible Roles Reference](ANSIBLE-ROLES-REFERENCE.md)** - Role details
- **[Deployment Decision Flowchart](DEPLOYMENT-DECISION-FLOWCHART.md)** - Workflow selection

### Community Support

- **Validated Patterns:** https://validatedpatterns.io
- **GitHub Issues:** https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues
- **OpenShift Documentation:** https://docs.openshift.com
- **Red Hat Hybrid Cloud Patterns:** https://hybrid-cloud-patterns.io

### Getting Help

1. **Check Documentation** - Review guides and troubleshooting
2. **Search Issues** - Look for similar problems on GitHub
3. **Enable Debug Mode** - Gather detailed logs
4. **Create Issue** - Report new problems with logs and details

---

**Document Version:** 1.0
**Last Updated:** 2025-10-27
**Maintained By:** Validated Patterns Toolkit Development Team
