# Quick Start Guide

## 5-Minute Setup

### 1. Build the Application
```bash
cd quarkus-reference-app
./mvnw clean package
```

### 2. Build Container Image
```bash
podman build -f src/main/docker/Dockerfile.jvm -t reference-app:latest .
```

### 3. Deploy to OpenShift (Dev)
```bash
# Create namespace
oc new-project reference-app-dev

# Deploy using Kustomize
oc apply -k k8s/overlays/dev

# Wait for deployment
oc rollout status deployment/dev-reference-app -n reference-app-dev
```

### 4. Test the Application
```bash
# Get the route
ROUTE=$(oc get route dev-reference-app -n reference-app-dev -o jsonpath='{.spec.host}')

# Test health
curl https://$ROUTE/health/live
curl https://$ROUTE/health/ready

# Test API
curl https://$ROUTE/api/example
```

## Common Commands

### Local Development
```bash
# Run in dev mode (hot reload)
./mvnw quarkus:dev

# Run tests
./mvnw test

# Build native image
./mvnw package -Pnative
```

### Kubernetes Operations
```bash
# View pods
oc get pods -n reference-app-dev

# View logs
oc logs -f deployment/dev-reference-app -n reference-app-dev

# Port forward
oc port-forward svc/dev-reference-app 8080:8080 -n reference-app-dev

# Scale deployment
oc scale deployment dev-reference-app --replicas=3 -n reference-app-dev

# Delete deployment
oc delete -k k8s/overlays/dev
```

### GitOps Deployment
```bash
# Deploy using ArgoCD
oc apply -f gitops/application.yaml

# Monitor sync
oc get application reference-app -n openshift-gitops -w

# Check ArgoCD status
oc describe application reference-app -n openshift-gitops
```

## API Examples

### Get All Examples
```bash
curl https://$ROUTE/api/example
```

### Create Example
```bash
curl -X POST https://$ROUTE/api/example \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Example",
    "description": "This is an example"
  }'
```

### Get Example by ID
```bash
curl https://$ROUTE/api/example/1
```

### Update Example
```bash
curl -X PUT https://$ROUTE/api/example/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Example",
    "description": "Updated description"
  }'
```

### Delete Example
```bash
curl -X DELETE https://$ROUTE/api/example/1
```

## Troubleshooting

### Pod not starting?
```bash
oc describe pod <pod-name> -n reference-app-dev
oc logs <pod-name> -n reference-app-dev
```

### Health check failing?
```bash
oc exec <pod-name> -n reference-app-dev -- curl localhost:8080/health/live
```

### Route not accessible?
```bash
oc get route -n reference-app-dev
oc get svc -n reference-app-dev
oc get endpoints -n reference-app-dev
```

## Documentation

- [README.md](README.md) - Overview
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) - Deployment guide
- [docs/CONFIGURATION.md](docs/CONFIGURATION.md) - Configuration (coming soon)
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) - Development guide (coming soon)
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Troubleshooting (coming soon)

## Next Steps

1. Customize the application for your needs
2. Update Kubernetes manifests
3. Deploy with validated-patterns-toolkit
4. Integrate with your CI/CD pipeline
