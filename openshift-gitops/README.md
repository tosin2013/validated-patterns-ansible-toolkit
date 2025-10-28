# OpenShift GitOps Installation

This directory contains Kubernetes manifests for installing and configuring OpenShift GitOps (ArgoCD) operator.

## Overview

OpenShift GitOps is a required prerequisite for deploying Validated Patterns. It provides:

- **GitOps Workflow**: Declarative application deployment
- **ArgoCD**: Continuous delivery for Kubernetes
- **Multi-Cluster Support**: Hub and spoke architecture
- **RBAC Integration**: OpenShift authentication

## Files

- **`operator.yaml`**: OpenShift GitOps operator subscription
- **`argocd.yaml`**: ArgoCD instance configuration with resource limits
- **`rbac.yaml`**: Cluster-admin permissions for ArgoCD service account
- **`kustomization.yaml`**: Kustomize configuration for all resources

## Installation Methods

### Method 1: Using Kustomize (Recommended)

```bash
# Apply all manifests
oc apply -k openshift-gitops/

# Verify installation
oc get csv -n openshift-operators | grep gitops
oc get argocd -n openshift-gitops
```

### Method 2: Using Ansible Playbook

```bash
# Run the installation playbook
ansible-playbook ansible/playbooks/install_gitops.yml

# Or with ansible-navigator
ansible-navigator run ansible/playbooks/install_gitops.yml -m stdout
```

### Method 3: Manual Installation

```bash
# Install operator
oc apply -f openshift-gitops/operator.yaml

# Wait for operator to be ready
oc wait --for=condition=Ready csv -l operators.coreos.com/openshift-gitops-operator.openshift-operators -n openshift-operators --timeout=300s

# Apply RBAC
oc apply -f openshift-gitops/rbac.yaml

# Create ArgoCD instance
oc apply -f openshift-gitops/argocd.yaml
```

## Configuration Details

### Operator Subscription

- **Channel**: `latest`
- **Source**: `redhat-operators`
- **Install Plan**: Automatic
- **Namespace**: `openshift-operators`

### ArgoCD Instance

**Resource Limits:**
- **Controller**: 2 CPU / 2Gi memory
- **Server**: 500m CPU / 256Mi memory
- **Repo Server**: 1 CPU / 1Gi memory
- **Redis**: 500m CPU / 256Mi memory
- **ApplicationSet**: 2 CPU / 1Gi memory

**Features:**
- OpenShift OAuth integration enabled
- Kustomize with Helm support enabled
- Tekton resources excluded from sync
- HA mode disabled (single instance)
- Grafana and Prometheus disabled

### RBAC Configuration

The ArgoCD application controller service account is granted `cluster-admin` permissions to:
- Deploy applications across all namespaces
- Manage cluster-scoped resources
- Support multi-cluster patterns

**Note**: In production, consider using more restrictive RBAC policies.

## Verification

### Check Operator Status

```bash
# Check operator CSV
oc get csv -n openshift-operators | grep gitops

# Expected output:
# openshift-gitops-operator.v1.x.x   Red Hat OpenShift GitOps   1.x.x   Succeeded
```

### Check ArgoCD Instance

```bash
# Check ArgoCD resource
oc get argocd -n openshift-gitops

# Check ArgoCD pods
oc get pods -n openshift-gitops

# Expected pods:
# - openshift-gitops-application-controller
# - openshift-gitops-applicationset-controller
# - openshift-gitops-dex-server
# - openshift-gitops-redis
# - openshift-gitops-repo-server
# - openshift-gitops-server
```

### Access ArgoCD UI

```bash
# Get ArgoCD route
oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}'

# Get admin password
oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d
```

## Troubleshooting

### Operator Not Installing

```bash
# Check operator pod logs
oc logs -n openshift-operators -l name=openshift-gitops-operator

# Check install plan
oc get installplan -n openshift-operators
```

### ArgoCD Instance Not Ready

```bash
# Check ArgoCD status
oc describe argocd openshift-gitops -n openshift-gitops

# Check pod events
oc get events -n openshift-gitops --sort-by='.lastTimestamp'

# Check pod logs
oc logs -n openshift-gitops -l app.kubernetes.io/name=openshift-gitops-server
```

### Permission Issues

```bash
# Verify RBAC
oc get clusterrolebinding openshift-gitops-cluster-admin

# Check service account
oc get sa openshift-gitops-argocd-application-controller -n openshift-gitops
```

## Uninstallation

```bash
# Delete ArgoCD instance
oc delete -f openshift-gitops/argocd.yaml

# Delete RBAC
oc delete -f openshift-gitops/rbac.yaml

# Delete operator subscription
oc delete -f openshift-gitops/operator.yaml

# Clean up namespace (optional)
oc delete namespace openshift-gitops
```

## Integration with Validated Patterns

After installation, the prerequisites role will validate:

1. ✅ Operator is installed and in "Succeeded" phase
2. ✅ ArgoCD instance is running
3. ✅ ArgoCD server is accessible
4. ✅ Required RBAC permissions are configured

## References

- [OpenShift GitOps Documentation](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Validated Patterns GitOps](https://validatedpatterns.io/learn/gitops/)
- [ADR-010: OpenShift GitOps Operator](../docs/adr/ADR-010-openshift-gitops-operator.md)

## Notes

- Installation typically takes 2-3 minutes
- Requires OpenShift 4.12 or higher
- Requires cluster-admin permissions
- Default configuration is suitable for development/testing
- For production, review and adjust resource limits
- Consider implementing more restrictive RBAC policies

---

**Last Updated**: 2025-10-25
**Maintained By**: Validated Patterns Team
