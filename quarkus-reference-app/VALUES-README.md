# Values Files Guide

This directory contains values files for the Quarkus Reference Application following the Validated Patterns framework requirements.

## Overview

The Validated Patterns framework requires **4 values files** for proper pattern deployment:

1. **values-global.yaml** - Global configuration shared across all clusters
2. **values-hub.yaml** - Hub cluster configuration and application definitions
3. **values-dev.yaml** - Development environment overrides
4. **values-prod.yaml** - Production environment overrides

Additionally, a **values-secrets.yaml** file is used for sensitive data (NEVER committed to Git).

---

## File Descriptions

### 1. values-global.yaml

**Purpose:** Global configuration shared across all clusters in the pattern.

**Contains:**
- Application name and namespace
- Default replica count
- Container image configuration
- Resource limits and requests
- Service and route configuration
- RBAC settings
- Health check configuration
- ArgoCD sync wave definitions
- Common labels and annotations

**Usage:**
```bash
helm install quarkus-reference-app ./charts/all/quarkus-reference-app \
  -f values-global.yaml
```

**Override Priority:** Lowest (overridden by cluster-specific and environment-specific values)

---

### 2. values-hub.yaml

**Purpose:** Hub cluster configuration for the Validated Patterns framework.

**Contains:**
- `clusterGroup` configuration for clustergroup chart integration
- Namespaces to create on the hub cluster
- Applications to deploy via ArgoCD
- Hub-specific resource overrides
- ArgoCD configuration
- Monitoring and backup settings

**Key Features:**
- Integrates with the clustergroup chart
- Defines ArgoCD applications
- Manages namespace creation
- Configures sync policies

**Usage:**
```bash
helm install quarkus-reference-app ./charts/all/quarkus-reference-app \
  -f values-global.yaml \
  -f values-hub.yaml
```

**Override Priority:** Medium (overrides values-global.yaml)

---

### 3. values-dev.yaml

**Purpose:** Development environment configuration.

**Contains:**
- Single replica for development
- Reduced resource limits (64Mi-128Mi memory)
- Development-specific configuration
- Relaxed health checks
- Latest image tag (always pull)
- Development labels and annotations

**Key Differences from Global:**
- `replicas: 1` (vs 2 in global)
- Lower resource limits
- `config.profile: dev`
- `config.environment: development`
- More tolerant health checks
- `image.pullPolicy: Always`

**Usage:**
```bash
helm install quarkus-reference-app ./charts/all/quarkus-reference-app \
  -f values-global.yaml \
  -f values-dev.yaml
```

**Override Priority:** High (overrides values-global.yaml)

---

### 4. values-prod.yaml

**Purpose:** Production environment configuration.

**Contains:**
- High availability with 3 replicas
- Production-grade resources (256Mi-512Mi memory)
- Pinned image version (v1.0.0)
- Strict health checks
- Custom production domain
- Monitoring and alerting
- Backup configuration
- Network policies
- Pod Disruption Budget
- Horizontal Pod Autoscaler

**Key Differences from Global:**
- `replicas: 3` (vs 2 in global)
- Higher resource limits
- `config.profile: prod`
- `config.environment: production`
- Pinned image tag (`v1.0.0`)
- `image.pullPolicy: IfNotPresent`
- Monitoring enabled
- Backup enabled
- Network policies enabled
- Autoscaling enabled

**Usage:**
```bash
helm install quarkus-reference-app ./charts/all/quarkus-reference-app \
  -f values-global.yaml \
  -f values-prod.yaml
```

**Override Priority:** High (overrides values-global.yaml)

---

### 5. values-secrets.yaml (NOT in Git)

**Purpose:** Sensitive data and credentials.

**Contains:**
- Database credentials
- API keys and tokens
- TLS certificates
- OAuth/OIDC secrets
- SMTP credentials
- Object storage credentials
- Custom application secrets

**IMPORTANT:**
- ⚠️ **NEVER commit this file to Git!**
- Use `values-secrets.yaml.template` as a starting point
- Store actual secrets in a secure vault
- Ensure `values-secrets.yaml` is in `.gitignore`

**Usage:**
```bash
# Create from template
cp values-secrets.yaml.template values-secrets.yaml

# Edit with actual secrets
vim values-secrets.yaml

# Deploy with secrets
helm install quarkus-reference-app ./charts/all/quarkus-reference-app \
  -f values-global.yaml \
  -f values-hub.yaml \
  -f values-secrets.yaml
```

**Override Priority:** Highest (overrides all other values)

---

## Values File Hierarchy

Values files are applied in order, with later files overriding earlier ones:

```
values-global.yaml          (Base configuration)
  ↓
values-hub.yaml            (Hub cluster overrides)
  ↓
values-{env}.yaml          (Environment overrides: dev, prod)
  ↓
values-secrets.yaml        (Secrets - highest priority)
```

---

## Common Usage Patterns

### Development Deployment
```bash
helm install quarkus-reference-app ./charts/all/quarkus-reference-app \
  -f values-global.yaml \
  -f values-dev.yaml \
  -n quarkus-dev \
  --create-namespace
```

### Production Deployment
```bash
helm install quarkus-reference-app ./charts/all/quarkus-reference-app \
  -f values-global.yaml \
  -f values-prod.yaml \
  -f values-secrets.yaml \
  -n quarkus-prod \
  --create-namespace
```

### Hub Cluster Deployment (via ArgoCD)
```bash
# The clustergroup chart will deploy this automatically
# using values-global.yaml and values-hub.yaml
```

### Dry Run (Test Configuration)
```bash
helm template test-release ./charts/all/quarkus-reference-app \
  -f values-global.yaml \
  -f values-dev.yaml
```

---

## Validated Patterns Framework Integration

### clustergroup Chart Integration

The `values-hub.yaml` file integrates with the Validated Patterns clustergroup chart:

```yaml
clusterGroup:
  name: hub
  isHubCluster: true

  namespaces:
    - quarkus-dev

  applications:
    quarkus-reference-app:
      name: quarkus-reference-app
      namespace: quarkus-dev
      path: quarkus-reference-app/charts/all/quarkus-reference-app
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

### Deployment Flow

1. **clustergroup chart** creates namespaces (Wave -1)
2. **clustergroup chart** deploys ArgoCD Application
3. **ArgoCD** syncs the Quarkus Helm chart
4. **Helm chart** deploys resources in sync wave order

---

## Best Practices

### 1. Never Commit Secrets
- Always use `values-secrets.yaml.template`
- Add `values-secrets.yaml` to `.gitignore`
- Use Sealed Secrets or External Secrets Operator for GitOps

### 2. Pin Versions in Production
- Use specific image tags (e.g., `v1.0.0`)
- Set `image.pullPolicy: IfNotPresent`
- Test in dev before promoting to prod

### 3. Environment-Specific Overrides
- Keep common configuration in `values-global.yaml`
- Override only what's different in environment files
- Document why overrides are needed

### 4. Resource Limits
- Set appropriate limits for each environment
- Monitor actual usage and adjust
- Use autoscaling in production

### 5. Health Checks
- Use relaxed checks in dev for faster iteration
- Use strict checks in prod for reliability
- Monitor health check failures

---

## Troubleshooting

### Values Not Applied
```bash
# Check which values are being used
helm get values quarkus-reference-app -n quarkus-dev

# Render templates to see final configuration
helm template test-release ./charts/all/quarkus-reference-app \
  -f values-global.yaml \
  -f values-dev.yaml
```

### Override Not Working
```bash
# Values files are applied in order
# Later files override earlier files
# Check the order of -f flags

# Correct order:
helm install ... -f values-global.yaml -f values-dev.yaml

# Wrong order (dev values will be overridden):
helm install ... -f values-dev.yaml -f values-global.yaml
```

### Secrets Not Loading
```bash
# Ensure values-secrets.yaml exists
ls -la values-secrets.yaml

# Check file is not in .gitignore for deployment
# (It should be in .gitignore for Git, but accessible for Helm)

# Verify secrets are being applied
helm template ... -f values-secrets.yaml | grep -A 5 "kind: Secret"
```

---

## References

- **Validated Patterns Documentation:** https://validatedpatterns.io
- **Helm Values Documentation:** https://helm.sh/docs/chart_template_guide/values_files/
- **ArgoCD Sync Waves:** https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/
- **Refactoring Plan:** `docs/REFACTORING-PLAN-QUARKUS-APP.md`
- **Phase 3 Report:** `docs/PHASE3-VALUES-FILES-COMPLETE.md`
