# Deployment Guide

## Prerequisites

- OpenShift 4.12+ cluster
- kubectl or oc CLI
- Docker or Podman
- Maven 3.8+
- Java 17+

## Build Application

### Build JAR
```bash
./mvnw clean package
```

### Build Container Image
```bash
# Using Podman
podman build -f src/main/docker/Dockerfile.jvm -t reference-app:latest .

# Using Docker
docker build -f src/main/docker/Dockerfile.jvm -t reference-app:latest .
```

### Push to Registry
```bash
# Tag image
podman tag reference-app:latest quay.io/your-org/reference-app:latest

# Push to registry
podman push quay.io/your-org/reference-app:latest
```

## Deploy to OpenShift

### Option 1: Using Kustomize (Dev)
```bash
# Create namespace
oc new-project reference-app-dev

# Deploy using dev overlay
oc apply -k k8s/overlays/dev
```

### Option 2: Using Kustomize (Prod)
```bash
# Create namespace
oc new-project reference-app

# Deploy using prod overlay
oc apply -k k8s/overlays/prod
```

### Option 3: Using GitOps (ArgoCD)
```bash
# Create ArgoCD Application
oc apply -f gitops/application.yaml

# Monitor sync
oc get application reference-app -n openshift-gitops -w
```

## Verify Deployment

### Check Pods
```bash
oc get pods -n reference-app
oc describe pod <pod-name> -n reference-app
oc logs <pod-name> -n reference-app
```

### Check Service
```bash
oc get svc -n reference-app
oc describe svc reference-app -n reference-app
```

### Check Route
```bash
oc get route -n reference-app
oc describe route reference-app -n reference-app
```

### Test Application
```bash
# Get route URL
ROUTE=$(oc get route reference-app -n reference-app -o jsonpath='{.spec.host}')

# Test health endpoints
curl https://$ROUTE/health/live
curl https://$ROUTE/health/ready

# Test API
curl https://$ROUTE/api/example
curl -X POST https://$ROUTE/api/example \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","description":"Test item"}'

# Get metrics
curl https://$ROUTE/metrics
```

## Configuration

### Update ConfigMap
```bash
oc edit configmap reference-app-config -n reference-app
```

### Update Replicas
Edit k8s/overlays/prod/kustomization.yaml:
```yaml
replicas:
- name: reference-app
  count: 5  # Change replica count
```

### Update Image
Edit k8s/base/kustomization.yaml:
```yaml
images:
- name: quay.io/validated-patterns/reference-app
  newTag: v1.0.1  # Change image tag
```

## Troubleshooting

### Pod not starting
```bash
oc describe pod <pod-name> -n reference-app
oc logs <pod-name> -n reference-app
```

### Health check failing
```bash
# Check liveness probe
oc exec <pod-name> -n reference-app -- curl localhost:8080/health/live

# Check readiness probe
oc exec <pod-name> -n reference-app -- curl localhost:8080/health/ready
```

### Route not accessible
```bash
# Check route
oc get route reference-app -n reference-app

# Check service
oc get svc reference-app -n reference-app

# Check endpoints
oc get endpoints reference-app -n reference-app
```

## Scaling

### Manual Scaling
```bash
oc scale deployment reference-app --replicas=5 -n reference-app
```

### Using Kustomize
Edit k8s/overlays/prod/kustomization.yaml and apply:
```bash
oc apply -k k8s/overlays/prod
```

## Updating Application

### Update Image
```bash
# Build new image
./mvnw clean package
podman build -f src/main/docker/Dockerfile.jvm -t reference-app:v1.0.1 .
podman push quay.io/your-org/reference-app:v1.0.1

# Update deployment
oc set image deployment/reference-app \
  reference-app=quay.io/your-org/reference-app:v1.0.1 \
  -n reference-app
```

### Rollback
```bash
oc rollout undo deployment/reference-app -n reference-app
```

## Cleanup

### Delete Deployment
```bash
oc delete -k k8s/overlays/prod
```

### Delete Namespace
```bash
oc delete project reference-app
```

### Delete ArgoCD Application
```bash
oc delete application reference-app -n openshift-gitops
```
