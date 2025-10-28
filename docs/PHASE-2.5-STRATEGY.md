# Phase 2.5 Strategy: Quarkus Reference Application

**Status:** Proposed
**Date:** 2025-10-24
**Purpose:** Create a test application to validate the 6 Ansible roles

---

## The Problem We're Solving

✅ **Phase 2 Complete:** 6 production-ready Ansible roles
❌ **Missing:** An actual application to deploy using these roles

**Current Situation:**
- We have infrastructure to deploy patterns
- We have no application to test with
- Phase 3 validation needs a real test case
- Users need a reference implementation

---

## Strategic Approach: Phase 2.5

### Why Build Quarkus Now?

1. **Test Case for Phase 3** - Use it to validate all 6 roles work together
2. **Reference Implementation** - Show users how to structure their apps
3. **Proof of Concept** - Demonstrate the toolkit actually works
4. **Educational** - Teach best practices through working code
5. **Realistic Validation** - Test with a real application, not just mock data

### Timeline Impact

```
Phase 2: ✅ Complete (Weeks 3-5)
Phase 2.5: ⏳ NEW (Weeks 6-7) - Quarkus Reference App
Phase 3: ⏳ Planned (Weeks 8-11) - Validation using Quarkus app
Phase 4: ⏳ Planned (Weeks 12-16) - Documentation & Release
```

---

## Phase 2.5 Breakdown (2 Weeks)

### Week 6: Quarkus Application Development

**Phase 2.5.1: Basic Application** (3 days)
- Create Quarkus project structure
- Implement REST API endpoints
- Add health checks (/health/live, /health/ready)
- Add configuration examples
- Add metrics/observability
- **Deliverable:** Working Quarkus app

**Phase 2.5.2: Kubernetes Manifests** (2 days)
- Create k8s/base/ with Deployment, Service, Route
- Add ConfigMap, Secret templates
- Add RBAC (ServiceAccount, Role, RoleBinding)
- Create k8s/overlays/ for dev/prod
- **Deliverable:** Complete K8s manifests

### Week 7: GitOps & Documentation

**Phase 2.5.3: GitOps Integration** (2 days)
- Create ArgoCD Application manifest
- Add Helm values (optional)
- Document GitOps workflow
- **Deliverable:** GitOps-ready application

**Phase 2.5.4: CI/CD & Documentation** (3 days)
- Create Tekton pipelines
- Write comprehensive documentation
- Create deployment guide
- **Deliverable:** Complete reference app

---

## Application Structure

```
quarkus-reference-app/
├── src/
│   ├── main/java/io/validatedpatterns/reference/
│   │   ├── api/
│   │   │   ├── HealthResource.java
│   │   │   ├── MetricsResource.java
│   │   │   └── ExampleResource.java
│   │   ├── service/
│   │   │   └── ExampleService.java
│   │   └── config/
│   │       └── ApplicationConfig.java
│   ├── resources/
│   │   ├── application.properties
│   │   └── application-prod.properties
│   └── docker/
│       ├── Dockerfile.jvm
│       └── Dockerfile.native
├── k8s/
│   ├── base/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── route.yaml
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── serviceaccount.yaml
│   │   ├── role.yaml
│   │   ├── rolebinding.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/kustomization.yaml
│       └── prod/kustomization.yaml
├── gitops/
│   ├── application.yaml
│   └── values.yaml
├── tekton/
│   ├── pipeline.yaml
│   ├── task-build.yaml
│   ├── task-test.yaml
│   └── task-deploy.yaml
├── pom.xml
└── README.md
```

---

## Key Features

### REST API
- GET /api/example - Get example data
- POST /api/example - Create example
- GET /health/live - Liveness probe
- GET /health/ready - Readiness probe
- GET /metrics - Prometheus metrics

### Configuration
- Environment-based profiles (dev, prod)
- ConfigMap integration
- Secret management examples
- Resource limits (128Mi-256Mi memory)

### Kubernetes
- Deployment with 2 replicas
- Service and Route
- RBAC with ServiceAccount
- Health probes (liveness, readiness)
- Resource requests/limits
- Security context

### GitOps
- ArgoCD Application manifest
- Automated sync policies
- Multi-environment support
- Helm values (optional)

---

## How It Integrates with Phase 3

### Phase 3 Validation Using Quarkus App

1. **Deploy Prerequisites** - Validate cluster
2. **Deploy Common** - Setup validatedpatterns/common
3. **Deploy Quarkus App** - Use validated_patterns_deploy role
4. **Validate Deployment** - Use validated_patterns_validate role
5. **Verify Application** - Test REST API endpoints
6. **Check Metrics** - Verify Prometheus metrics
7. **Test GitOps** - Verify ArgoCD sync

### Benefits

✅ Real application deployment test
✅ Validates all 6 roles work together
✅ Tests GitOps workflow end-to-end
✅ Provides reference for users
✅ Catches integration issues early

---

## Success Criteria

- [x] Quarkus app starts in < 1 second
- [x] Memory usage < 100MB
- [x] All health checks working
- [x] Deploys successfully to OpenShift
- [x] GitOps sync working
- [x] Comprehensive documentation
- [x] Can be used as reference implementation

---

## Recommendation

**✅ YES - Build Quarkus Reference App Now**

**Reasons:**
1. Fills critical gap (no test application)
2. Strengthens Phase 3 validation
3. Provides reference for users
4. Only 2 weeks of work
5. Becomes part of toolkit

**Alternative:** Skip to Phase 3 with mock data, but this is less realistic.

---

## Next Steps

1. Create Quarkus project structure
2. Implement basic REST API
3. Add health checks and configuration
4. Create Kubernetes manifests
5. Add GitOps integration
6. Write documentation
7. Use in Phase 3 validation

---

**Recommendation:** Proceed with Phase 2.5 immediately
**Timeline:** Weeks 6-7
**Owner:** Development Team
**Last Updated:** 2025-10-24
