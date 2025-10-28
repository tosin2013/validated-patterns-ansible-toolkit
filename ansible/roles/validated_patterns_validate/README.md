# validated_patterns_validate

Comprehensive validation framework for Validated Patterns.

## Purpose

This role provides comprehensive validation:

- Pre-deployment validation
- Deployment monitoring
- Post-deployment verification
- Health checks

## Requirements

- Ansible 2.12+
- kubernetes.core collection
- OpenShift cluster access

## Role Variables

```yaml
validated_patterns_namespace: "validated-patterns"
validated_patterns_validation_timeout: 300
validated_patterns_validate_pre_deployment: true
validated_patterns_validate_deployment: true
validated_patterns_validate_post_deployment: true
validated_patterns_validate_health: true
```

## Usage

```yaml
- name: Validate deployment
  hosts: localhost
  gather_facts: no
  roles:
    - validated_patterns_validate
```

## License

Apache 2.0
