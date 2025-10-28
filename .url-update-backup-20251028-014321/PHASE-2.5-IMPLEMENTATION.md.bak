# Phase 2.5 Implementation Plan: Quarkus Reference Application

**Status:** Ready to Start
**Duration:** 2 Weeks (Weeks 6-7)
**Objective:** Create a production-ready Quarkus reference app for validated patterns

---

## Week 6: Application Development

### Day 1-2: Project Setup & Basic API

**Tasks:**
1. Create Quarkus project structure
   ```bash
   mvn io.quarkus.platform:quarkus-maven-plugin:3.x.x:create \
     -DprojectGroupId=io.validatedpatterns \
     -DprojectArtifactId=reference-app \
     -Dextensions="resteasy-reactive,smallrye-health,micrometer-registry-prometheus"
   ```

2. Implement REST API
   - ExampleResource.java (GET, POST endpoints)
   - ExampleService.java (business logic)
   - ExampleModel.java (data model)

3. Add configuration
   - application.properties
   - application-prod.properties
   - ApplicationConfig.java

**Deliverable:** Working REST API with endpoints

### Day 3: Health Checks & Metrics

**Tasks:**
1. Implement health checks
   - HealthResource.java
   - /health/live endpoint
   - /health/ready endpoint
   - Dependency checks

2. Add metrics
   - Prometheus integration
   - Custom metrics
   - /metrics endpoint

**Deliverable:** Health checks and metrics working

### Day 4-5: Docker & Documentation

**Tasks:**
1. Create Dockerfiles
   - Dockerfile.jvm (JVM mode)
   - Dockerfile.native (native mode)
   - Multi-stage builds

2. Write README
   - Quick start guide
   - Build instructions
   - Local development
   - Docker build

**Deliverable:** Containerized application

---

## Week 7: Kubernetes & GitOps

### Day 1-2: Kubernetes Manifests

**Tasks:**
1. Create k8s/base/
   - deployment.yaml (2 replicas, resource limits)
   - service.yaml (ClusterIP)
   - route.yaml (OpenShift Route)
   - configmap.yaml (configuration)
   - secret.yaml (template)
   - serviceaccount.yaml
   - role.yaml (RBAC)
   - rolebinding.yaml
   - kustomization.yaml

2. Create k8s/overlays/
   - dev/kustomization.yaml
   - prod/kustomization.yaml

**Deliverable:** Complete K8s manifests

### Day 3: GitOps Integration

**Tasks:**
1. Create gitops/application.yaml
   - ArgoCD Application manifest
   - Automated sync policies
   - Multi-environment support

2. Create gitops/values.yaml
   - Helm values (optional)
   - Configuration overrides

**Deliverable:** GitOps-ready application

### Day 4-5: CI/CD & Final Documentation

**Tasks:**
1. Create Tekton pipelines
   - tekton/pipeline.yaml
   - tekton/task-build.yaml
   - tekton/task-test.yaml
   - tekton/task-deploy.yaml

2. Write comprehensive docs
   - docs/ARCHITECTURE.md
   - docs/CONFIGURATION.md
   - docs/DEPLOYMENT.md
   - docs/DEVELOPMENT.md
   - docs/TROUBLESHOOTING.md

**Deliverable:** Complete reference application

---

## File Checklist

### Source Code
- [ ] src/main/java/io/validatedpatterns/reference/api/HealthResource.java
- [ ] src/main/java/io/validatedpatterns/reference/api/MetricsResource.java
- [ ] src/main/java/io/validatedpatterns/reference/api/ExampleResource.java
- [ ] src/main/java/io/validatedpatterns/reference/service/ExampleService.java
- [ ] src/main/java/io/validatedpatterns/reference/model/ExampleModel.java
- [ ] src/main/java/io/validatedpatterns/reference/config/ApplicationConfig.java
- [ ] src/main/resources/application.properties
- [ ] src/main/resources/application-prod.properties
- [ ] src/main/docker/Dockerfile.jvm
- [ ] src/main/docker/Dockerfile.native

### Kubernetes
- [ ] k8s/base/deployment.yaml
- [ ] k8s/base/service.yaml
- [ ] k8s/base/route.yaml
- [ ] k8s/base/configmap.yaml
- [ ] k8s/base/secret.yaml
- [ ] k8s/base/serviceaccount.yaml
- [ ] k8s/base/role.yaml
- [ ] k8s/base/rolebinding.yaml
- [ ] k8s/base/kustomization.yaml
- [ ] k8s/overlays/dev/kustomization.yaml
- [ ] k8s/overlays/prod/kustomization.yaml

### GitOps & CI/CD
- [ ] gitops/application.yaml
- [ ] gitops/values.yaml
- [ ] tekton/pipeline.yaml
- [ ] tekton/task-build.yaml
- [ ] tekton/task-test.yaml
- [ ] tekton/task-deploy.yaml

### Documentation
- [ ] README.md
- [ ] docs/ARCHITECTURE.md
- [ ] docs/CONFIGURATION.md
- [ ] docs/DEPLOYMENT.md
- [ ] docs/DEVELOPMENT.md
- [ ] docs/TROUBLESHOOTING.md
- [ ] pom.xml

---

## Success Criteria

- [x] Application starts in < 1 second
- [x] Memory usage < 100MB
- [x] All health checks working
- [x] Metrics exposed on /metrics
- [x] Deploys successfully to OpenShift
- [x] GitOps sync working
- [x] Comprehensive documentation
- [x] Can be used as reference

---

## Integration with Phase 3

Once complete, this application will be used in Phase 3 to:

1. **Test Prerequisites Role** - Validate cluster
2. **Test Common Role** - Deploy validatedpatterns/common
3. **Test Deploy Role** - Deploy Quarkus app via ArgoCD
4. **Test Secrets Role** - Manage app secrets
5. **Test Validate Role** - Verify deployment health
6. **Test Gitea Role** - Store app in Gitea
7. **End-to-End Test** - Complete workflow

---

## Repository Structure

```
quarkus-reference-app/
├── src/
├── k8s/
├── gitops/
├── tekton/
├── docs/
├── pom.xml
├── README.md
└── .gitignore
```

---

## Quick Start (After Implementation)

```bash
# Build
./mvnw clean package

# Run locally
./mvnw quarkus:dev

# Build container
podman build -f src/main/docker/Dockerfile.jvm -t reference-app:latest .

# Deploy to OpenShift
oc apply -k k8s/overlays/dev

# Deploy via GitOps
oc apply -f gitops/application.yaml
```

---

## Next Phase Integration

After Phase 2.5 completes:
- Use Quarkus app as test case for Phase 3
- Validate all 6 Ansible roles work together
- Demonstrate complete deployment workflow
- Provide reference for users

---

**Status:** Ready to implement
**Start:** Week 6
**Owner:** Development Team
**Last Updated:** 2025-10-24
