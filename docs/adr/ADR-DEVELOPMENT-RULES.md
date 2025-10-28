# Development Rules for Validated Patterns Template

**Version:** 1.0
**Last Updated:** 2025-01-24
**Status:** Active

## Purpose

This document establishes development rules and guidelines for the Validated Patterns Template project. All contributors must follow these rules to maintain code quality, consistency, and alignment with project goals.

## Core Principles

### 1. Sophia's Methodological Pragmatism

All development follows the principles outlined in "The Pragmatic Coders":

- **Explicit Fallibilism**: Acknowledge limitations and uncertainties
- **Systematic Verification**: Establish structured validation processes
- **Pragmatic Success Criteria**: Prioritize what works reliably
- **Cognitive Systematization**: Organize knowledge coherently

### 2. Idempotency First

- All Ansible tasks MUST be idempotent
- Multiple executions MUST produce the same result
- Use `changed_when` clauses for accurate reporting
- Test idempotency in CI/CD pipelines

### 3. Validation at Every Stage

- Pre-deployment validation
- During-deployment monitoring
- Post-deployment verification
- Continuous validation

## Architecture Decision Records (ADRs)

### ADR Workflow

1. **Propose**: Create ADR with "Proposed" status
2. **Review**: Team reviews and provides feedback
3. **Decide**: Team makes decision, update status to "Accepted" or "Rejected"
4. **Implement**: Implement according to ADR
5. **Supersede**: If needed, create new ADR and mark old one as "Superseded"

### ADR Template

```markdown
# ADR-XXX: Title

**Status:** Proposed | Accepted | Rejected | Superseded
**Date:** YYYY-MM-DD
**Decision Makers:** Names
**Consulted:** Names
**Informed:** Names

## Context and Problem Statement
[Describe the context and problem]

## Decision Drivers
[List key factors influencing the decision]

## Considered Options
[List and briefly describe options]

## Decision Outcome
[Describe the chosen option and rationale]

## Consequences
[Describe positive and negative consequences]

## References
[List relevant references]
```

### Current ADRs

- [ADR-001: Project Vision and Scope](ADR-001-project-vision-and-scope.md)
- [ADR-002: Ansible Role Architecture](ADR-002-ansible-role-architecture.md)
- [ADR-003: Validation Framework](ADR-003-validation-framework.md)
- [ADR-004: Quarkus Management Application](ADR-004-quarkus-management-application.md)
- [ADR-005: Gitea Development Environment](ADR-005-gitea-development-environment.md)
- [ADR-006: Execution Context Handling](ADR-006-execution-context-handling.md)

## Development Workflow

### 1. Feature Development

```bash
# Create feature branch
git checkout -b feature/ADR-XXX-feature-name

# Develop with frequent commits
git commit -m "feat(component): description"

# Keep branch updated
git rebase main

# Push and create PR
git push origin feature/ADR-XXX-feature-name
```

### 2. Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(ansible): add validated_patterns_deploy role

Implements the core deployment role for Validated Patterns.
Includes idempotent tasks for operator installation and
GitOps configuration.

Refs: ADR-002
```

### 3. Pull Request Process

1. **Create PR** with clear description
2. **Link ADR** if implementing architectural decision
3. **Add tests** for new functionality
4. **Update documentation** as needed
5. **Request review** from at least 2 team members
6. **Address feedback** promptly
7. **Squash commits** before merge

### 4. Code Review Guidelines

**Reviewers must check:**
- [ ] Code follows ADR guidelines
- [ ] Idempotency is maintained
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No hardcoded secrets or credentials
- [ ] Error handling is comprehensive
- [ ] Logging is appropriate

## Coding Standards

### Ansible

```yaml
# Good: Idempotent, clear, well-documented
- name: Deploy OpenShift GitOps Operator
  k8s:
    state: present
    definition:
      apiVersion: operators.coreos.com/v1alpha1
      kind: Subscription
      metadata:
        name: openshift-gitops-operator
        namespace: openshift-operators
      spec:
        channel: stable
        name: openshift-gitops-operator
        source: redhat-operators
        sourceNamespace: openshift-marketplace
  register: gitops_operator
  tags: ['operators', 'gitops']

# Bad: Not idempotent, unclear
- name: Install operator
  shell: oc apply -f operator.yaml
```

**Ansible Rules:**
- Use `k8s` module instead of `shell` for Kubernetes resources
- Always use `state: present` or `state: absent`
- Include `register` for important tasks
- Use `tags` for selective execution
- Add meaningful task names
- Use `block/rescue/always` for error handling

### Bash Scripts

```bash
# Good: Error handling, clear, documented
#!/bin/bash
set -euo pipefail

# Detect execution context
detect_context() {
    if [ -n "${PATTERN_SUBDIRECTORY:-}" ]; then
        echo "subdirectory"
    else
        echo "root"
    fi
}

# Main execution
main() {
    local context=$(detect_context)
    echo "Running in ${context} context"

    # Your logic here
}

main "$@"

# Bad: No error handling, unclear
#!/bin/bash
cd /some/path
./script.sh
```

**Bash Rules:**
- Always use `set -euo pipefail`
- Use functions for reusability
- Quote variables: `"${VAR}"`
- Use `local` for function variables
- Add comments for complex logic
- Handle errors explicitly

### Java/Quarkus

```java
// Good: Clear, documented, error handling
@Path("/api/patterns")
@Produces(MediaType.APPLICATION_JSON)
public class PatternResource {

    @Inject
    PatternService patternService;

    @GET
    @Path("/{name}")
    public Response getPattern(@PathParam("name") String name) {
        try {
            Pattern pattern = patternService.getPattern(name);
            return Response.ok(pattern).build();
        } catch (PatternNotFoundException e) {
            return Response.status(Response.Status.NOT_FOUND)
                .entity(new ErrorResponse(e.getMessage()))
                .build();
        }
    }
}

// Bad: No error handling, unclear
@GET
public Pattern get(String n) {
    return service.get(n);
}
```

**Java Rules:**
- Use dependency injection
- Handle exceptions appropriately
- Use meaningful names
- Add JavaDoc for public APIs
- Follow REST best practices
- Use DTOs for API responses

### YAML/Kubernetes

```yaml
# Good: Complete, documented, resource limits
apiVersion: apps/v1
kind: Deployment
metadata:
  name: validated-patterns-manager
  namespace: validated-patterns
  labels:
    app: validated-patterns-manager
    version: v1.0.0
spec:
  replicas: 1
  selector:
    matchLabels:
      app: validated-patterns-manager
  template:
    metadata:
      labels:
        app: validated-patterns-manager
    spec:
      containers:
      - name: manager
        image: quay.io/validated-patterns/manager:latest
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"

# Bad: Incomplete, no resource limits
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
      - name: app
        image: app:latest
```

**Kubernetes Rules:**
- Always specify resource requests and limits
- Use meaningful labels
- Include health checks (liveness/readiness)
- Use namespaces appropriately
- Version your resources
- Document with comments

## Testing Requirements

### 1. Ansible Testing

```bash
# Run molecule tests
cd ansible/roles/validated_patterns_deploy
molecule test

# Run playbook in check mode
ansible-playbook playbooks/deploy_pattern.yml --check

# Test idempotency
ansible-playbook playbooks/deploy_pattern.yml
ansible-playbook playbooks/deploy_pattern.yml  # Should show no changes
```

### 2. Quarkus Testing

```bash
# Run unit tests
cd quarkus-app
./mvnw test

# Run integration tests
./mvnw verify

# Run in dev mode
./mvnw quarkus:dev
```

### 3. End-to-End Testing

```bash
# Deploy on test cluster
make deploy-pattern PATTERN_NAME=multicloud-gitops

# Run validation
make validate-pattern PATTERN_NAME=multicloud-gitops

# Run Tekton validation pipeline
oc create -f tekton/pipelineruns/validate-multicloud-gitops.yaml
```

## Documentation Requirements

### 1. Code Documentation

- **Ansible**: Task names must be descriptive
- **Bash**: Functions must have comments
- **Java**: Public APIs must have JavaDoc
- **YAML**: Complex configurations need comments

### 2. User Documentation

Follow [Diátaxis framework](https://diataxis.fr/):

- **Tutorials**: Learning-oriented, step-by-step guides
- **How-To Guides**: Task-oriented, problem-solving guides
- **Reference**: Information-oriented, technical descriptions
- **Explanation**: Understanding-oriented, conceptual discussions

### 3. ADR Documentation

- Create ADR for significant architectural decisions
- Update ADRs when decisions change
- Link code to relevant ADRs

## Security Requirements

### 1. Secrets Management

```yaml
# Good: Use external secrets
- name: Configure vault secrets
  include_role:
    name: validated_patterns_secrets
  vars:
    vault_url: "{{ vault_url }}"
    vault_token: "{{ lookup('env', 'VAULT_TOKEN') }}"

# Bad: Hardcoded secrets
- name: Set password
  set_fact:
    db_password: "hardcoded_password"  # NEVER DO THIS
```

**Rules:**
- NEVER commit secrets to Git
- Use environment variables or external secret management
- Use Ansible Vault for sensitive playbook variables
- Rotate secrets regularly

### 2. Container Security

- Use minimal base images
- Scan images for vulnerabilities
- Run as non-root user
- Use read-only root filesystem where possible

## Continuous Integration

### 1. Pre-Commit Checks

```bash
# Install pre-commit hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

### 2. CI Pipeline

All PRs must pass:
- [ ] Linting (ansible-lint, shellcheck, etc.)
- [ ] Unit tests
- [ ] Integration tests
- [ ] Security scans
- [ ] Documentation build

## Maintenance and Support

### 1. Issue Triage

- **P0 (Critical)**: Security issues, data loss - Fix immediately
- **P1 (High)**: Broken functionality - Fix within 1 week
- **P2 (Medium)**: Degraded functionality - Fix within 1 month
- **P3 (Low)**: Nice to have - Backlog

### 2. Version Support

- **Current version**: Full support
- **Previous version**: Security fixes only
- **Older versions**: No support

## References

- [Validated Patterns Documentation](https://validatedpatterns.io/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Diátaxis Framework](https://diataxis.fr/)
- [The Pragmatic Coders](https://pragmaticcoders.dev/)
