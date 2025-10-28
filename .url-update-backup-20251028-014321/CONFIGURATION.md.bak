# Configuration Guide

## Overview

The Quarkus reference application supports multiple configuration methods:
- Environment variables
- application.properties files
- ConfigMaps (Kubernetes)
- Secrets (Kubernetes)
- External configuration services

## Application Properties

### Default Configuration (application.properties)

```properties
# Application info
quarkus.application.name=validated-patterns-reference
quarkus.application.version=1.0.0

# HTTP configuration
quarkus.http.port=8080
quarkus.http.host=0.0.0.0

# Health checks
quarkus.smallrye-health.root-path=/health

# Metrics
quarkus.micrometer.enabled=true
quarkus.micrometer.export.prometheus.enabled=true

# Logging
quarkus.log.level=INFO
quarkus.log.console.format=%d{HH:mm:ss} %-5p [%c{2.}] (%t) %s%e%n
```

### Environment Profiles

#### Development Profile
```properties
%dev.quarkus.log.level=DEBUG
%dev.quarkus.http.port=8080
```

#### Production Profile
```properties
%prod.quarkus.log.level=INFO
%prod.quarkus.http.port=8080
```

## Environment Variables

### Setting Profile
```bash
export QUARKUS_PROFILE=prod
```

### Logging Configuration
```bash
export QUARKUS_LOG_LEVEL=DEBUG
export QUARKUS_LOG_CONSOLE_FORMAT=%d{HH:mm:ss} %-5p [%c{2.}] (%t) %s%e%n
```

### HTTP Configuration
```bash
export QUARKUS_HTTP_PORT=8080
export QUARKUS_HTTP_HOST=0.0.0.0
```

## Kubernetes ConfigMap

### Create ConfigMap
```bash
oc create configmap reference-app-config \
  --from-literal=app.name=reference-app \
  --from-literal=app.version=1.0.0 \
  --from-literal=app.environment=production \
  -n reference-app
```

### Update ConfigMap
```bash
oc edit configmap reference-app-config -n reference-app
```

### ConfigMap in Deployment
```yaml
env:
- name: APP_CONFIG
  valueFrom:
    configMapKeyRef:
      name: reference-app-config
      key: app.config
      optional: true
```

## Kubernetes Secrets

### Create Secret
```bash
oc create secret generic reference-app-secret \
  --from-literal=db-password=secret123 \
  --from-literal=api-key=key123 \
  -n reference-app
```

### Use Secret in Deployment
```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: reference-app-secret
      key: db-password
```

## Customization

### Change Application Name
Edit `pom.xml`:
```xml
<groupId>io.yourorg</groupId>
<artifactId>your-app</artifactId>
<version>1.0.0</version>
```

### Change Package Name
1. Update `src/main/java/io/yourorg/yourapp/`
2. Update `application.properties`
3. Update Kubernetes manifests

### Change Port
```bash
# In application.properties
quarkus.http.port=9000

# In deployment.yaml
ports:
- containerPort: 9000
  name: http
```

### Change Replicas
Edit `k8s/overlays/prod/kustomization.yaml`:
```yaml
replicas:
- name: reference-app
  count: 5  # Change replica count
```

### Change Image Registry
Edit `k8s/base/kustomization.yaml`:
```yaml
images:
- name: quay.io/validated-patterns/reference-app
  newName: your-registry.com/your-org/reference-app
  newTag: v1.0.0
```

## Resource Configuration

### Memory Limits
Edit `k8s/base/deployment.yaml`:
```yaml
resources:
  requests:
    memory: "256Mi"  # Change request
  limits:
    memory: "512Mi"  # Change limit
```

### CPU Limits
```yaml
resources:
  requests:
    cpu: "200m"      # Change request
  limits:
    cpu: "1000m"     # Change limit
```

## Health Check Configuration

### Liveness Probe
```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 3
  failureThreshold: 3
```

### Readiness Probe
```yaml
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

## Logging Configuration

### Log Levels
```bash
# TRACE, DEBUG, INFO, WARN, ERROR
export QUARKUS_LOG_LEVEL=DEBUG
```

### Log Format
```bash
export QUARKUS_LOG_CONSOLE_FORMAT=%d{HH:mm:ss} %-5p [%c{2.}] (%t) %s%e%n
```

### Log Categories
```properties
quarkus.log.category."io.validatedpatterns".level=DEBUG
quarkus.log.category."org.hibernate".level=WARN
```

## Metrics Configuration

### Enable Metrics
```properties
quarkus.micrometer.enabled=true
quarkus.micrometer.export.prometheus.enabled=true
```

### Metrics Endpoint
```bash
curl http://localhost:8080/metrics
```

## Security Configuration

### HTTPS/TLS
```properties
quarkus.http.ssl.certificate.files=path/to/cert.pem
quarkus.http.ssl.certificate.key-files=path/to/key.pem
```

### CORS
```properties
quarkus.http.cors=true
quarkus.http.cors.origins=*
```

## Database Configuration (Future)

When adding database support:

```properties
# PostgreSQL
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=postgres
quarkus.datasource.password=password
quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/mydb
```

## Troubleshooting Configuration

### Enable Debug Logging
```bash
export QUARKUS_LOG_LEVEL=DEBUG
./mvnw quarkus:dev
```

### Check Configuration
```bash
# In dev mode, visit:
http://localhost:8080/q/dev/config-editor
```

### View Active Configuration
```bash
oc exec <pod-name> -n reference-app -- env | grep QUARKUS
```

## Best Practices

1. **Use ConfigMaps for non-sensitive configuration**
2. **Use Secrets for sensitive data**
3. **Use environment profiles for different environments**
4. **Document all custom configuration**
5. **Use reasonable defaults**
6. **Validate configuration on startup**
7. **Log configuration changes**
8. **Use external configuration services for complex setups**

## References

- [Quarkus Configuration Guide](https://quarkus.io/guides/config)
- [Kubernetes ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
