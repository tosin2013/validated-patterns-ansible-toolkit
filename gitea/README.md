# Gitea Development Environment

This directory contains scripts and configurations for deploying Gitea on OpenShift using the Red Hat GPTE Gitea Operator.

## Overview

Gitea provides a self-hosted Git service for:
- Testing Validated Patterns locally
- Development and experimentation
- Training and workshops
- Air-gapped environments
- CI/CD testing

## Quick Start

### Deploy Gitea

```bash
# Deploy with defaults
./scripts/deploy-gitea.sh

# Or with custom configuration
GITEA_USER_NUMBER=5 ./scripts/deploy-gitea.sh
```

### Get Credentials

```bash
# Retrieve credentials
./scripts/get-credentials.sh

# For different namespace/instance
./scripts/get-credentials.sh my-namespace my-gitea-instance
```

## Configuration

Environment variables for `deploy-gitea.sh`:

| Variable | Default | Description |
|----------|---------|-------------|
| `GITEA_OPERATOR_NAMESPACE` | `gitea-operator` | Operator namespace |
| `GITEA_NAMESPACE` | `gitea` | Gitea instance namespace |
| `GITEA_INSTANCE_NAME` | `gitea-with-admin` | Gitea CR name |
| `GITEA_ADMIN_USER` | `opentlc-mgr` | Admin username |
| `GITEA_ADMIN_EMAIL` | `opentlc-mgr@redhat.com` | Admin email |
| `GITEA_ADMIN_PASSWORD_LENGTH` | `32` | Admin password length |
| `GITEA_CREATE_USERS` | `true` | Create lab users |
| `GITEA_USER_FORMAT` | `lab-user` | Lab user prefix |
| `GITEA_USER_NUMBER` | `1` | Number of lab users |
| `GITEA_USER_PASSWORD_LENGTH` | `16` | Lab user password length |
| `GITEA_SSL` | `true` | Enable SSL/TLS |

## Directory Structure

```
gitea/
├── scripts/
│   ├── deploy-gitea.sh          # Deploy Gitea with operator
│   ├── get-credentials.sh       # Retrieve credentials
│   ├── create-organizations.sh  # Create organizations (TODO)
│   └── mirror-repositories.sh   # Mirror pattern repos (TODO)
├── instance/
│   └── gitea-instance.yaml      # Example Gitea CR
└── README.md                    # This file
```

## Usage Examples

### Example 1: Deploy for Single User

```bash
# Deploy with single admin user
GITEA_CREATE_USERS=false ./scripts/deploy-gitea.sh
```

### Example 2: Deploy for Training (5 Users)

```bash
# Deploy with 5 lab users
GITEA_USER_NUMBER=5 ./scripts/deploy-gitea.sh
```

### Example 3: Custom Configuration

```bash
# Deploy with custom settings
GITEA_NAMESPACE=my-gitea \
GITEA_INSTANCE_NAME=my-instance \
GITEA_ADMIN_USER=admin \
GITEA_ADMIN_EMAIL=admin@example.com \
./scripts/deploy-gitea.sh
```

### Example 4: Check Deployment Status

```bash
# Check Gitea CR status
oc get gitea -n gitea

# Check pods
oc get pods -n gitea

# Check route
oc get route -n gitea

# Get detailed status
oc describe gitea gitea-with-admin -n gitea
```

## Integration with Validated Patterns

### Use Gitea as ArgoCD Source

```yaml
# In your pattern values file
main:
  git:
    repoURL: https://gitea-with-admin-gitea.apps.cluster-domain.com/validated-patterns/multicloud-gitops.git
    targetRevision: main
```

### Deploy Pattern with Gitea

```bash
# Using Ansible
ansible-playbook ansible/playbooks/deploy_pattern.yml \
  -e pattern_name=multicloud-gitops \
  -e pattern_git_url=https://gitea-with-admin-gitea.apps.cluster-domain.com/validated-patterns/multicloud-gitops.git \
  -e git_insecure=true
```

## Troubleshooting

### Check Operator Status

```bash
# Check operator pods
oc get pods -n gitea-operator

# Check operator logs
oc logs -n gitea-operator -l control-plane=controller-manager --tail=50
```

### Check Gitea Instance

```bash
# Get Gitea CR details
oc describe gitea gitea-with-admin -n gitea

# Check Gitea pods
oc get pods -n gitea

# Check Gitea logs
oc logs -n gitea deployment/gitea-with-admin

# Check PostgreSQL logs
oc logs -n gitea deployment/postgresql-gitea-with-admin
```

### Common Issues

#### Operator Not Deploying

```bash
# Check if operator namespace exists
oc get namespace gitea-operator

# Redeploy operator
oc delete -k https://github.com/rhpds/gitea-operator/OLMDeploy
sleep 30
oc apply -k https://github.com/rhpds/gitea-operator/OLMDeploy
```

#### Gitea Instance Not Ready

```bash
# Check events
oc get events -n gitea --sort-by='.lastTimestamp'

# Check CR status
oc get gitea gitea-with-admin -n gitea -o yaml

# Delete and recreate
oc delete gitea gitea-with-admin -n gitea
./scripts/deploy-gitea.sh
```

#### Cannot Access Gitea URL

```bash
# Check route
oc get route -n gitea

# Test connectivity
GITEA_URL=$(oc get gitea gitea-with-admin -n gitea -o jsonpath='{.status.giteaRoute}')
curl -k -I "${GITEA_URL}"
```

## Cleanup

### Delete Gitea Instance

```bash
# Delete instance (keeps operator)
oc delete gitea gitea-with-admin -n gitea
oc delete project gitea
```

### Delete Everything

```bash
# Delete instance and operator
oc delete gitea gitea-with-admin -n gitea
oc delete project gitea
oc delete -k https://github.com/rhpds/gitea-operator/OLMDeploy
oc delete project gitea-operator
```

## References

- [Red Hat GPTE Gitea Operator](https://github.com/rhpds/gitea-operator)
- [Gitea Documentation](https://docs.gitea.io/)
- [Validated Patterns](https://validatedpatterns.io/)
- [ADR-005: Gitea Development Environment](../docs/adr/ADR-005-gitea-development-environment.md)

## Support

For issues or questions:
1. Check the [troubleshooting section](#troubleshooting)
2. Review [ADR-005](../docs/adr/ADR-005-gitea-development-environment.md)
3. Check operator logs
4. Open an issue on GitHub
