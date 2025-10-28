# Troubleshooting Guide

## Common Issues and Solutions

### Build Issues

#### Maven Build Fails
**Problem:** `./mvnw clean package` fails

**Solutions:**
```bash
# Clear Maven cache
rm -rf ~/.m2/repository

# Rebuild
./mvnw clean package -U

# Check Java version
java -version  # Should be 17+

# Check Maven version
mvn -version   # Should be 3.8+
```

#### Dependency Resolution Fails
**Problem:** Cannot download dependencies

**Solutions:**
```bash
# Check internet connection
ping repo.maven.apache.org

# Use different Maven repository
mvn -Dmaven.repo.local=/tmp/mvn-repo clean package

# Clear local repository
rm -rf ~/.m2/repository
mvn clean package
```

#### Compilation Errors
**Problem:** Java compilation fails

**Solutions:**
```bash
# Check Java version
java -version

# Verify source/target in pom.xml
# Should have: <maven.compiler.release>17</maven.compiler.release>

# Clean and rebuild
./mvnw clean compile
```

### Local Development Issues

#### Port Already in Use
**Problem:** `Port 8080 already in use`

**Solutions:**
```bash
# Find process using port
lsof -i :8080
netstat -tulpn | grep 8080

# Kill process
kill -9 <PID>

# Or use different port
export QUARKUS_HTTP_PORT=8081
./mvnw quarkus:dev
```

#### Hot Reload Not Working
**Problem:** Changes not reflected in dev mode

**Solutions:**
```bash
# Restart dev mode
# Press Ctrl+C and run again
./mvnw quarkus:dev

# Check file permissions
chmod 644 src/main/java/io/validatedpatterns/reference/**/*.java

# Rebuild
./mvnw clean compile
```

#### Out of Memory
**Problem:** `java.lang.OutOfMemoryError`

**Solutions:**
```bash
# Increase heap size
export MAVEN_OPTS="-Xmx1024m"
./mvnw quarkus:dev

# Or in pom.xml
<argLine>-Xmx1024m</argLine>
```

### Container Build Issues

#### Docker Build Fails
**Problem:** `podman build` fails

**Solutions:**
```bash
# Ensure JAR is built
./mvnw clean package

# Check Dockerfile path
podman build -f src/main/docker/Dockerfile.jvm -t reference-app:latest .

# View build output
podman build -f src/main/docker/Dockerfile.jvm -t reference-app:latest . --log-level debug

# Check base image
podman pull registry.access.redhat.com/ubi9/openjdk-17:latest
```

#### Image Too Large
**Problem:** Container image is very large

**Solutions:**
```bash
# Use native image (smaller)
./mvnw package -Pnative
podman build -f src/main/docker/Dockerfile.native -t reference-app:native .

# Check image size
podman images reference-app

# Use multi-stage build
# See Dockerfile.jvm for example
```

#### Image Won't Run
**Problem:** Container exits immediately

**Solutions:**
```bash
# Check logs
podman run reference-app:latest

# Run with interactive terminal
podman run -it reference-app:latest /bin/bash

# Check entrypoint
podman inspect reference-app:latest | grep -A 5 Entrypoint
```

### Kubernetes Deployment Issues

#### Pod Won't Start
**Problem:** Pod stuck in `Pending` or `CrashLoopBackOff`

**Solutions:**
```bash
# Check pod status
oc describe pod <pod-name> -n reference-app

# View logs
oc logs <pod-name> -n reference-app

# Check events
oc get events -n reference-app

# Check resource availability
oc describe nodes

# Check image pull
oc get pods -n reference-app -o jsonpath='{.items[*].status.containerStatuses[*].imageID}'
```

#### Image Pull Fails
**Problem:** `ImagePullBackOff` error

**Solutions:**
```bash
# Check image exists
podman images reference-app

# Push to registry
podman tag reference-app:latest quay.io/your-org/reference-app:latest
podman push quay.io/your-org/reference-app:latest

# Update deployment image
oc set image deployment/reference-app \
  reference-app=quay.io/your-org/reference-app:latest \
  -n reference-app

# Check image pull secrets
oc get secrets -n reference-app
```

#### Insufficient Resources
**Problem:** Pod pending due to resource constraints

**Solutions:**
```bash
# Check node resources
oc describe nodes

# Reduce resource requests in deployment.yaml
resources:
  requests:
    memory: "64Mi"   # Reduce from 128Mi
    cpu: "50m"       # Reduce from 100m

# Apply changes
oc apply -k k8s/overlays/dev
```

### Health Check Issues

#### Liveness Probe Failing
**Problem:** Pod restarting due to failed liveness probe

**Solutions:**
```bash
# Test health endpoint
oc exec <pod-name> -n reference-app -- curl localhost:8080/health/live

# Check logs for errors
oc logs <pod-name> -n reference-app

# Increase initial delay
# In deployment.yaml:
livenessProbe:
  initialDelaySeconds: 30  # Increase from 5

# Apply changes
oc apply -k k8s/overlays/dev
```

#### Readiness Probe Failing
**Problem:** Pod not receiving traffic

**Solutions:**
```bash
# Test readiness endpoint
oc exec <pod-name> -n reference-app -- curl localhost:8080/health/ready

# Check application startup
oc logs <pod-name> -n reference-app | grep -i ready

# Increase initial delay
# In deployment.yaml:
readinessProbe:
  initialDelaySeconds: 10  # Increase from 5

# Apply changes
oc apply -k k8s/overlays/dev
```

### Service and Route Issues

#### Service Not Accessible
**Problem:** Cannot reach service

**Solutions:**
```bash
# Check service exists
oc get svc -n reference-app

# Check endpoints
oc get endpoints -n reference-app

# Port forward to test
oc port-forward svc/reference-app 8080:8080 -n reference-app
curl http://localhost:8080/api/example

# Check service selector
oc get svc reference-app -n reference-app -o yaml | grep selector
```

#### Route Not Working
**Problem:** Cannot access via route URL

**Solutions:**
```bash
# Check route exists
oc get route -n reference-app

# Get route URL
oc get route reference-app -n reference-app -o jsonpath='{.spec.host}'

# Test route
ROUTE=$(oc get route reference-app -n reference-app -o jsonpath='{.spec.host}')
curl https://$ROUTE/api/example

# Check TLS certificate
oc describe route reference-app -n reference-app

# Check ingress controller
oc get pods -n openshift-ingress
```

### GitOps Issues

#### ArgoCD Application Not Syncing
**Problem:** Application stuck in `OutOfSync`

**Solutions:**
```bash
# Check application status
oc describe application reference-app -n openshift-gitops

# View sync status
oc get application reference-app -n openshift-gitops -o yaml

# Force sync
oc patch application reference-app -n openshift-gitops \
  -p '{"spec":{"syncPolicy":{"syncOptions":["Refresh=hard"]}}}' \
  --type merge

# Check ArgoCD logs
oc logs -f deployment/argocd-application-controller -n openshift-gitops
```

#### Repository Access Denied
**Problem:** ArgoCD cannot access Git repository

**Solutions:**
```bash
# Check repository credentials
oc get secret -n openshift-gitops | grep repo

# Create repository secret
oc create secret generic repo-creds \
  --from-literal=username=<user> \
  --from-literal=password=<token> \
  -n openshift-gitops

# Update application to use secret
# In gitops/application.yaml:
source:
  repoURL: https://github.com/...
  password: <token>
```

### API Issues

#### Endpoint Returns 404
**Problem:** API endpoint not found

**Solutions:**
```bash
# Check endpoint path
curl http://localhost:8080/api/example

# List available endpoints
curl http://localhost:8080/q/openapi

# Check resource class
grep -r "@Path" src/main/java/

# Verify deployment
oc logs <pod-name> -n reference-app | grep -i "registered"
```

#### Endpoint Returns 500
**Problem:** Internal server error

**Solutions:**
```bash
# Check logs
oc logs <pod-name> -n reference-app

# Enable debug logging
export QUARKUS_LOG_LEVEL=DEBUG
./mvnw quarkus:dev

# Check request format
curl -X POST http://localhost:8080/api/example \
  -H "Content-Type: application/json" \
  -d '{"name":"test"}'
```

### Performance Issues

#### Slow Response Times
**Problem:** API responses are slow

**Solutions:**
```bash
# Check resource usage
oc top pods -n reference-app

# Check logs for errors
oc logs <pod-name> -n reference-app

# Increase replicas
oc scale deployment reference-app --replicas=3 -n reference-app

# Check metrics
curl http://localhost:8080/metrics
```

#### High Memory Usage
**Problem:** Pod using too much memory

**Solutions:**
```bash
# Check memory usage
oc top pods -n reference-app

# Reduce heap size in Dockerfile
# Or increase pod memory limit

# Check for memory leaks
# Enable profiling and analyze
```

## Getting Help

### Check Logs
```bash
# Application logs
oc logs <pod-name> -n reference-app

# Follow logs
oc logs -f <pod-name> -n reference-app

# Previous logs (if pod crashed)
oc logs <pod-name> -n reference-app --previous
```

### Describe Resources
```bash
# Pod details
oc describe pod <pod-name> -n reference-app

# Deployment details
oc describe deployment reference-app -n reference-app

# Service details
oc describe svc reference-app -n reference-app
```

### Check Events
```bash
# Recent events
oc get events -n reference-app

# Watch events
oc get events -n reference-app -w
```

### Debug Pod
```bash
# Execute command in pod
oc exec <pod-name> -n reference-app -- <command>

# Open shell
oc exec -it <pod-name> -n reference-app -- /bin/bash

# Copy files
oc cp reference-app/<pod-name>:/path/to/file ./local/path
```

## Resources

- [Quarkus Troubleshooting](https://quarkus.io/guides/troubleshooting)
- [OpenShift Debugging](https://docs.openshift.com/container-platform/latest/support/troubleshooting/index.html)
- [Kubernetes Debugging](https://kubernetes.io/docs/tasks/debug-application-cluster/)
