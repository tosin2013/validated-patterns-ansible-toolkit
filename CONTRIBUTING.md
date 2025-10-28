# Contributing to Validated Patterns Ansible Toolkit

Thank you for your interest in contributing to the Validated Patterns Ansible Toolkit! This project is a **reference implementation and reusable toolkit** for deploying Validated Patterns on OpenShift.

## 🎯 Project Purpose

This repository serves multiple purposes:
- **Reference Implementation**: Example of how to deploy Validated Patterns using Ansible
- **Reusable Toolkit**: 7 production-ready Ansible roles you can copy into your own projects
- **Template Repository**: Clone, fork, or copy to create your own pattern deployments
- **Example Applications**: Quarkus app, OpenShift AI notebooks, or any workload

## 🤝 How to Contribute

We welcome contributions in several forms:

### 1. **Ansible Roles** (Most Valuable)
- Improve existing roles (validated_patterns_*)
- Add new features to roles
- Fix bugs in role logic
- Improve role documentation
- Add role examples

### 2. **Reference Applications**
- Add new reference applications (beyond Quarkus)
- Improve existing Quarkus reference app
- Add OpenShift AI notebook examples
- Add other workload examples

### 3. **Documentation**
- Improve guides (DEVELOPER-GUIDE.md, END-USER-GUIDE.md)
- Add tutorials and how-tos
- Fix typos and clarify instructions
- Add examples of using roles in other projects
- Update Architecture Decision Records (ADRs)

### 4. **Testing & Validation**
- Add integration tests
- Improve validation playbooks
- Add security tests
- Test on different OpenShift versions

### 5. **Security**
- Report security vulnerabilities (see SECURITY.md)
- Improve gitleaks rules
- Add security best practices
- Improve secret management

## 🚀 Getting Started

### Prerequisites

- OpenShift cluster (4.12+)
- Ansible 2.15+
- Podman or Docker
- Git
- Pre-commit framework (for contributors)

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/validated-patterns-ansible-toolkit.git
   cd validated-patterns-ansible-toolkit
   ```

2. **Install Pre-commit Hooks** (Required for contributors)
   ```bash
   pip install pre-commit
   pre-commit install
   ```
   
   See [CONTRIBUTING-PRE-COMMIT.md](docs/CONTRIBUTING-PRE-COMMIT.md) for details.

3. **Install Ansible Collections**
   ```bash
   ansible-galaxy collection install -r files/requirements.yml
   ```

4. **Build Execution Environment** (Optional)
   ```bash
   make build
   ```

### Making Changes

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Follow existing code style
   - Update documentation
   - Add tests if applicable
   - Run pre-commit checks

3. **Test Your Changes**
   ```bash
   # Test Ansible roles
   make test
   
   # Run pre-commit checks
   pre-commit run --all-files
   
   # Test specific role
   ansible-playbook tests/integration/test_<role>.yml
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: Add your feature description"
   ```
   
   **Commit Message Format**:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `test:` - Test additions/changes
   - `chore:` - Maintenance tasks
   - `refactor:` - Code refactoring
   - `security:` - Security improvements

5. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```
   
   Then create a Pull Request on GitHub.

## 📋 Pull Request Guidelines

### Before Submitting

- [ ] Pre-commit hooks pass (`pre-commit run --all-files`)
- [ ] All tests pass (`make test`)
- [ ] Documentation updated (if applicable)
- [ ] ADR created/updated (for architectural changes)
- [ ] Commit messages follow format
- [ ] No secrets in code (gitleaks will check)

### PR Description Should Include

- **What**: Brief description of changes
- **Why**: Reason for changes
- **How**: Implementation approach
- **Testing**: How you tested the changes
- **Screenshots**: If UI/output changes

### Example PR Description

```markdown
## What
Add support for custom Helm values in validated_patterns_deploy role

## Why
Users need to override default Helm values for their specific deployments

## How
- Added `custom_helm_values` variable to role defaults
- Updated deploy_pattern.yml to merge custom values
- Added validation for custom values format

## Testing
- Tested with custom values on OpenShift 4.14
- Integration test added: tests/integration/test_custom_values.yml
- Pre-commit hooks pass

## Related Issues
Closes #123
```

## 🧪 Testing

### Running Tests

```bash
# All tests
make test

# Specific role test
ansible-playbook tests/integration/test_prerequisites.yml

# Validation tests
ansible-playbook tests/integration/test_validate.yml
```

### Adding Tests

When adding new features, please add corresponding tests:

1. **Unit Tests**: For individual role tasks
2. **Integration Tests**: For end-to-end workflows
3. **Validation Tests**: For deployment verification

Place tests in `tests/integration/` directory.

## 📚 Documentation Standards

### Ansible Role Documentation

Each role should have:
- `README.md` - Role overview and usage
- `defaults/main.yml` - Well-commented default variables
- `meta/main.yml` - Role metadata and dependencies
- Examples in role README

### Architecture Decision Records (ADRs)

For significant architectural changes, create an ADR:

```bash
# ADRs are in docs/adr/
# Follow existing format (see ADR-001 through ADR-014)
```

ADR should include:
- **Status**: Proposed, Accepted, Deprecated, Superseded
- **Context**: Why this decision is needed
- **Decision**: What was decided
- **Consequences**: Impact of the decision

### Code Comments

- Comment complex logic
- Explain "why" not "what"
- Use YAML comments for Ansible tasks
- Keep comments up-to-date

## 🔒 Security

### Secret Management

**NEVER commit secrets!** Pre-commit hooks will prevent this, but:

- Use Ansible Vault for sensitive data
- Use environment variables for tokens
- Use sealed secrets for Kubernetes secrets
- Reference secrets, don't embed them

### Reporting Security Issues

See [SECURITY.md](SECURITY.md) for reporting security vulnerabilities.

## 🎨 Code Style

### Ansible Style

- Use 2-space indentation
- Use lowercase with underscores for variable names
- Use descriptive task names
- Use `name:` for all tasks
- Group related tasks with comments
- Use `tags:` for task organization

### YAML Style

- 2-space indentation
- No tabs
- Lowercase keys with hyphens
- Files end with `.yml`
- Line length: 120 characters (warning at 160)

### Python Style (if applicable)

- Follow PEP 8
- Use type hints
- Add docstrings
- Use meaningful variable names

## 🏷️ Issue Labels

We use the following labels:

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Documentation improvements
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `security` - Security-related issues
- `question` - Further information requested
- `wontfix` - This will not be worked on

## 📞 Getting Help

- **GitHub Discussions**: Ask questions, share ideas
- **GitHub Issues**: Report bugs, request features
- **Documentation**: Check guides and ADRs
- **Examples**: See `tests/` and `quarkus-reference-app/`

## 📜 License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0.

This license allows others to:
- ✅ Copy and use the code
- ✅ Modify the code
- ✅ Distribute the code
- ✅ Use commercially

See [LICENSE](LICENSE) for full details.

## 🙏 Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes
- Project documentation

Thank you for contributing to the Validated Patterns Ansible Toolkit! 🎉

