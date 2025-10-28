# Architecture Guide

## Overview

This Quarkus reference application demonstrates best practices for cloud-native applications deployed with the validated-patterns-toolkit.

## Application Structure

```
src/main/java/io/validatedpatterns/reference/
├── api/
│   ├── HealthResource.java      # Health check endpoints
│   └── ExampleResource.java     # REST API endpoints
├── service/
│   └── ExampleService.java      # Business logic
├── model/
│   └── ExampleModel.java        # Data models
└── config/
    └── ApplicationConfig.java   # Configuration
```

## Key Components

### REST API (ExampleResource)
- GET /api/example - Get all examples
- GET /api/example/{id} - Get example by ID
- POST /api/example - Create new example
- PUT /api/example/{id} - Update example
- DELETE /api/example/{id} - Delete example

### Health Checks (HealthResource)
- GET /health/live - Liveness probe (is app running?)
- GET /health/ready - Readiness probe (can app serve traffic?)

### Business Logic (ExampleService)
- In-memory data store
- CRUD operations
- UUID generation for new items

### Data Model (ExampleModel)
- Simple POJO with id, name, description, status
- Serializable to JSON

## Kubernetes Architecture

### Deployment
- 2 replicas (configurable via Kustomize)
- Resource limits: 128Mi-256Mi memory, 100m-500m CPU
- Health probes: liveness and readiness
- Security context: non-root user, no privilege escalation

### Service
- ClusterIP service
- Port 8080 (HTTP)
- Selector: app=reference-app

### Route (OpenShift)
- HTTPS with edge termination
- Automatic redirect from HTTP to HTTPS
- Exposes service externally

### RBAC
- ServiceAccount for pod identity
- Role with permissions for ConfigMaps and Secrets
- RoleBinding to grant permissions

## GitOps Architecture

### ArgoCD Integration
- Application manifest in gitops/application.yaml
- Automated sync policies (prune, selfHeal)
- Automatic namespace creation
- Retry logic for failed syncs

### Kustomize Overlays
- Base configuration in k8s/base/
- Dev overlay: 1 replica, dev image tag
- Prod overlay: 3 replicas, latest image tag

## Configuration Management

### Environment Profiles
- Dev profile: DEBUG logging
- Prod profile: INFO logging

### ConfigMap
- Application configuration
- Mounted as environment variables

### Secrets (Optional)
- Template provided for sensitive data
- Can be managed by sealed-secrets or external-secrets

## Observability

### Health Checks
- Liveness probe: checks if app is running
- Readiness probe: checks if app can serve traffic
- Both return JSON status

### Metrics
- Prometheus metrics on /metrics
- Micrometer integration
- Custom metrics can be added

### Logging
- Structured logging with timestamps
- Configurable log levels
- Console output

## Performance Characteristics

- **Startup Time:** < 1 second
- **Memory Usage:** < 100MB
- **CPU Usage:** Minimal (100m request, 500m limit)
- **Throughput:** Suitable for reference implementation

## Security

- Non-root user (UID 1000)
- No privilege escalation
- Dropped all capabilities
- HTTPS with edge termination
- RBAC for pod permissions

## Deployment Flow

1. Build application with Maven
2. Build container image
3. Push to registry
4. Deploy via Kustomize or GitOps
5. ArgoCD syncs application
6. Pods start with health checks
7. Service routes traffic
8. Route exposes externally

## Customization Points

1. **API Endpoints:** Modify ExampleResource.java
2. **Business Logic:** Modify ExampleService.java
3. **Data Model:** Modify ExampleModel.java
4. **Configuration:** Update application.properties
5. **Kubernetes:** Modify k8s/ manifests
6. **GitOps:** Update gitops/application.yaml
7. **Replicas:** Modify Kustomize overlays
8. **Resources:** Update deployment.yaml limits

## Next Steps

- Copy this application
- Rename packages and classes
- Implement your business logic
- Update Kubernetes manifests
- Deploy with validated-patterns-toolkit
