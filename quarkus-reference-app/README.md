# Validated Patterns Reference Application

A production-ready Quarkus application demonstrating best practices for applications deployed with the validated-patterns-toolkit.

## Purpose

This is a **reference implementation** showing:
- ✅ Cloud-native application structure
- ✅ Kubernetes resource configuration
- ✅ GitOps integration patterns
- ✅ Health checks and observability
- ✅ Secrets management
- ✅ Resource management
- ✅ CI/CD with Tekton

## Quick Start

### Build
```bash
./mvnw clean package
```

### Run Locally
```bash
./mvnw quarkus:dev
```

### Build Container
```bash
podman build -f src/main/docker/Dockerfile.jvm -t reference-app:latest .
```

### Deploy to OpenShift
```bash
# Using Kustomize
oc apply -k k8s/overlays/dev

# Using GitOps (ArgoCD)
oc apply -f gitops/application.yaml
```

## API Endpoints

- `GET /api/example` - Get example data
- `POST /api/example` - Create example
- `GET /health/live` - Liveness probe
- `GET /health/ready` - Readiness probe
- `GET /metrics` - Prometheus metrics

## Features

### REST API
- Example endpoints for CRUD operations
- Proper error handling
- Request/response validation

### Health Checks
- Liveness probe (/health/live)
- Readiness probe (/health/ready)
- Dependency checks

### Observability
- Prometheus metrics (/metrics)
- Structured logging
- Request tracing

### Configuration
- Environment-based profiles (dev, prod)
- ConfigMap integration
- Secret management examples

### Kubernetes
- Deployment with 2 replicas
- Service and OpenShift Route
- RBAC with ServiceAccount
- Resource limits (128Mi-256Mi memory)
- Security context

### GitOps
- ArgoCD Application manifest
- Automated sync policies
- Multi-environment support

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Configuration](docs/CONFIGURATION.md)
- [Deployment](docs/DEPLOYMENT.md)
- [Development](docs/DEVELOPMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Performance

- ✅ Starts in < 1 second
- ✅ Memory usage < 100MB
- ✅ Production-ready

## Customization

Copy this application and customize for your needs:
1. Rename packages and classes
2. Update Kubernetes manifests
3. Modify GitOps configuration
4. Add your business logic
5. Deploy with validated-patterns-toolkit

## Not a Management Tool

This is NOT a management application for validated-patterns-toolkit.
It's a reference showing how YOUR applications should be structured.

## License

Apache 2.0
