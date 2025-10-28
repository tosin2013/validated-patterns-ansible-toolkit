# Tekton CI/CD Pipelines

This directory contains Tekton pipeline definitions for building, testing, and deploying the Quarkus reference application.

## Overview

The pipeline includes the following stages:

1. **Clone Repository** - Clone source code from Git
2. **Build Application** - Build with Maven
3. **Run Tests** - Execute unit tests
4. **Build Image** - Build container image with Buildah
5. **Deploy Application** - Deploy to Kubernetes with Kustomize
6. **Verify Deployment** - Verify application health

## Prerequisites

- OpenShift 4.12+ with Tekton Pipelines installed
- Tekton CLI (tkn) installed
- ServiceAccount with appropriate permissions
- PersistentVolume for workspace

## Installation

### 1. Install Tekton Pipelines

```bash
# Install Tekton Pipelines operator
oc apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Wait for installation
oc wait --for=condition=ready pod -l app=tekton-pipelines-controller -n tekton-pipelines --timeout=300s
```

### 2. Create Namespace

```bash
oc new-project reference-app
```

### 3. Create ServiceAccount

```bash
oc create serviceaccount pipeline-sa -n reference-app

# Grant permissions
oc adm policy add-scc-to-user privileged -z pipeline-sa -n reference-app
oc adm policy add-role-to-user edit -z pipeline-sa -n reference-app
```

### 4. Create PersistentVolume

```bash
# Create PVC for workspace
oc apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace
  namespace: reference-app
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
EOF
```

### 5. Deploy Pipeline Resources

```bash
# Create tasks
oc apply -f task-build.yaml
oc apply -f task-test.yaml
oc apply -f task-deploy.yaml
oc apply -f task-verify.yaml

# Create pipeline
oc apply -f pipeline.yaml
```

## Usage

### Run Pipeline Manually

```bash
# Create PipelineRun
oc apply -f pipelinerun-example.yaml

# Monitor execution
tkn pipelinerun logs reference-app-run-1 -f -n reference-app

# Check status
oc get pipelinerun -n reference-app
```

### Run with Custom Parameters

```bash
tkn pipeline start reference-app-pipeline \
  --param git-url=https://github.com/your-org/reference-app.git \
  --param git-revision=main \
  --param image-registry=quay.io \
  --param image-namespace=your-org \
  --param image-name=reference-app \
  --param image-tag=v1.0.0 \
  --param deploy-namespace=reference-app \
  --workspace name=shared-workspace,volumeClaimTemplateFile=pvc.yaml \
  --serviceaccount pipeline-sa \
  -n reference-app
```

### View Pipeline Logs

```bash
# View all logs
tkn pipelinerun logs reference-app-run-1 -n reference-app

# View specific task logs
tkn pipelinerun logs reference-app-run-1 -t build-app -n reference-app

# Follow logs in real-time
tkn pipelinerun logs reference-app-run-1 -f -n reference-app
```

### Check Pipeline Status

```bash
# List all runs
oc get pipelinerun -n reference-app

# Describe specific run
oc describe pipelinerun reference-app-run-1 -n reference-app

# Watch status
oc get pipelinerun -n reference-app -w
```

## Pipeline Tasks

### task-build.yaml
Builds the Quarkus application using Maven.

**Parameters:**
- MAVEN_IMAGE: Maven container image (default: maven:3.8-openjdk-17)
- GOALS: Maven goals to run (default: clean package -DskipTests)
- MAVEN_MIRROR_URL: Optional Maven mirror URL

**Outputs:**
- Built JAR in target/quarkus-app/

### task-test.yaml
Runs unit tests using Maven.

**Parameters:**
- MAVEN_IMAGE: Maven container image
- TEST_GOALS: Maven test goals (default: test)
- MAVEN_MIRROR_URL: Optional Maven mirror URL

**Outputs:**
- Test reports in target/surefire-reports/
- Coverage report in target/site/jacoco/

### task-deploy.yaml
Deploys the application to Kubernetes using Kustomize.

**Parameters:**
- IMAGE: Container image to deploy
- NAMESPACE: Target namespace (default: reference-app)
- OVERLAY: Kustomize overlay (dev or prod)
- KUBECTL_IMAGE: kubectl container image

**Actions:**
- Creates namespace
- Applies Kustomize overlay
- Waits for rollout
- Verifies pods and service

### task-verify.yaml
Verifies the deployment is healthy.

**Parameters:**
- NAMESPACE: Target namespace
- DEPLOYMENT: Deployment name
- KUBECTL_IMAGE: kubectl container image

**Checks:**
- Deployment status
- Pod readiness
- API endpoints
- Metrics endpoint
- Application logs

## Customization

### Modify Pipeline

Edit `pipeline.yaml` to:
- Add new tasks
- Change task order
- Add parameters
- Modify workspaces

### Modify Tasks

Edit individual task files to:
- Change build commands
- Add validation steps
- Modify deployment logic
- Add custom verification

### Add Webhook Integration

```bash
# Create EventListener for GitHub webhooks
oc apply -f - <<EOF
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: reference-app-listener
  namespace: reference-app
spec:
  serviceAccountName: pipeline-sa
  triggers:
  - name: github-push
    bindings:
    - ref: github-binding
    template:
      ref: reference-app-template
EOF
```

## Troubleshooting

### Pipeline Fails at Build Step

```bash
# Check build logs
tkn pipelinerun logs reference-app-run-1 -t build-app -f -n reference-app

# Common issues:
# - Maven cache issues: Clear ~/.m2/repository
# - Java version: Ensure Java 17+
# - Dependencies: Check network connectivity
```

### Pipeline Fails at Deploy Step

```bash
# Check deploy logs
tkn pipelinerun logs reference-app-run-1 -t deploy-app -f -n reference-app

# Common issues:
# - Image not found: Verify image registry and credentials
# - Namespace issues: Check namespace exists and permissions
# - Resource limits: Verify cluster has available resources
```

### Workspace Issues

```bash
# Check PVC status
oc get pvc -n reference-app

# Check PVC usage
oc exec <pod> -n reference-app -- df -h /workspace

# Increase PVC size if needed
oc patch pvc pipeline-workspace -n reference-app -p '{"spec":{"resources":{"requests":{"storage":"10Gi"}}}}'
```

## Best Practices

1. **Use specific image tags** - Avoid using `latest` tag
2. **Set resource limits** - Prevent resource exhaustion
3. **Use ServiceAccounts** - Implement least privilege
4. **Monitor pipeline runs** - Track success/failure rates
5. **Implement retry logic** - Handle transient failures
6. **Use workspaces** - Share data between tasks
7. **Document parameters** - Make pipelines reusable
8. **Test locally first** - Validate before running in CI/CD

## References

- [Tekton Documentation](https://tekton.dev/docs/)
- [Tekton Pipelines](https://tekton.dev/docs/pipelines/)
- [Tekton Tasks](https://tekton.dev/docs/pipelines/tasks/)
- [Tekton Triggers](https://tekton.dev/docs/triggers/)
