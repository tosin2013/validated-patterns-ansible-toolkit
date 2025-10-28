# Pull Request

## Description

<!-- Provide a clear and concise description of your changes -->

## Type of Change

<!-- Mark the relevant option with an 'x' -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🧪 Test addition or update
- [ ] 🔧 Configuration change
- [ ] ♻️ Code refactoring
- [ ] 🔒 Security improvement

## Related Issues

<!-- Link to related issues using #issue_number -->

Closes #
Relates to #

## Changes Made

<!-- List the specific changes made in this PR -->

- 
- 
- 

## Motivation and Context

<!-- Why is this change required? What problem does it solve? -->

## How Has This Been Tested?

<!-- Describe the tests you ran to verify your changes -->

- [ ] Test A: Description
- [ ] Test B: Description

**Test Configuration**:
- OpenShift version:
- Ansible version:
- Operating System:
- Container Engine:

## Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

## Checklist

<!-- Mark completed items with an 'x' -->

### Code Quality
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings or errors

### Testing
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] I have tested this on a real OpenShift cluster (if applicable)

### Documentation
- [ ] I have updated the documentation accordingly
- [ ] I have updated the relevant ADR (if architectural change)
- [ ] I have added/updated examples (if applicable)
- [ ] I have updated the CHANGELOG.md (if applicable)

### Security
- [ ] Pre-commit hooks pass (`pre-commit run --all-files`)
- [ ] Gitleaks scan passes (no secrets in code)
- [ ] I have not introduced any security vulnerabilities
- [ ] I have used `no_log: true` for sensitive data in Ansible tasks

### Ansible-Specific (if applicable)
- [ ] Role variables are documented in `defaults/main.yml`
- [ ] Role has a README.md with usage examples
- [ ] Tasks have descriptive names
- [ ] Idempotency is maintained (can run multiple times safely)
- [ ] Role follows Ansible best practices

## Additional Notes

<!-- Add any additional notes for reviewers -->

## Reviewer Checklist

<!-- For maintainers reviewing this PR -->

- [ ] Code review completed
- [ ] Tests pass in CI/CD
- [ ] Documentation is adequate
- [ ] Security considerations addressed
- [ ] Breaking changes documented (if any)
- [ ] Ready to merge

---

**By submitting this pull request, I confirm that my contribution is made under the terms of the GNU General Public License v3.0.**

