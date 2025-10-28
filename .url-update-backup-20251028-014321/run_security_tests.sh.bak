#!/bin/bash
# Week 10 Task 3: Security Validation Test Runner
# Runs all security tests for RBAC, secrets, and network policies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/../results"

# Test tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Week 10 - Security Validation Test Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print section header
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Function to run a test
run_test() {
    local test_name=$1
    local test_file=$2

    echo -e "${YELLOW}Running: ${test_name}${NC}"
    echo ""

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if ansible-playbook -i ../inventory "${test_file}"; then
        echo ""
        echo -e "${GREEN}✅ ${test_name} - PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo ""
        echo -e "${RED}❌ ${test_name} - FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Prerequisites check
print_header "Prerequisites Check"

echo "Checking required tools..."
MISSING_TOOLS=0

if ! command -v oc &> /dev/null; then
    echo -e "${RED}❌ oc (OpenShift CLI) not found${NC}"
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
else
    echo -e "${GREEN}✅ oc found: $(oc version --client | head -n1)${NC}"
fi

if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}❌ ansible-playbook not found${NC}"
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
else
    echo -e "${GREEN}✅ ansible-playbook found: $(ansible-playbook --version | head -n1)${NC}"
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found${NC}"
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
else
    echo -e "${GREEN}✅ kubectl found: $(kubectl version --client --short 2>/dev/null || kubectl version --client)${NC}"
fi

if [ $MISSING_TOOLS -gt 0 ]; then
    echo ""
    echo -e "${RED}Error: Missing required tools. Please install them and try again.${NC}"
    exit 1
fi

echo ""
echo "Checking cluster access..."
if ! oc whoami &> /dev/null; then
    echo -e "${RED}❌ Not logged into OpenShift cluster${NC}"
    echo "Please login using: oc login <cluster-url>"
    exit 1
else
    echo -e "${GREEN}✅ Logged in as: $(oc whoami)${NC}"
    echo -e "${GREEN}✅ Cluster: $(oc whoami --show-server)${NC}"
fi

echo ""
echo "Checking cluster permissions..."
if oc auth can-i create secrets -n validated-patterns-secrets &> /dev/null; then
    echo -e "${GREEN}✅ Can create secrets${NC}"
else
    echo -e "${YELLOW}⚠️  Limited permissions for secrets management${NC}"
fi

if oc auth can-i create networkpolicies &> /dev/null; then
    echo -e "${GREEN}✅ Can create network policies${NC}"
else
    echo -e "${YELLOW}⚠️  Limited permissions for network policies${NC}"
fi

# Create results directory
mkdir -p "${RESULTS_DIR}"

# Run tests
print_header "Test 1: RBAC Security Validation"
run_test "RBAC Security Test" "test_rbac.yml"
RBAC_TEST_RESULT=$?

print_header "Test 2: Secrets Management Validation"
run_test "Secrets Management Test" "test_secrets.yml"
SECRETS_TEST_RESULT=$?

print_header "Test 3: Network Policies Validation"
run_test "Network Policies Test" "test_network_policies.yml"
NETPOL_TEST_RESULT=$?

# Generate summary report
print_header "Test Summary"

echo "Test Results:"
echo "  Total Tests: ${TESTS_TOTAL}"
echo "  Passed: ${TESTS_PASSED}"
echo "  Failed: ${TESTS_FAILED}"
echo ""

if [ ${TESTS_FAILED} -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    EXIT_CODE=0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    EXIT_CODE=1
fi

echo ""
echo "Test reports saved to: ${RESULTS_DIR}"
echo ""

# Generate combined report
print_header "Generating Combined Report"

cat > "${RESULTS_DIR}/security_report.md" << EOF
# Security Validation Report

**Test Date:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Test Suite:** Week 10 - Security Validation
**Cluster:** $(oc whoami --show-server)
**User:** $(oc whoami)

## Test Summary

| Test | Status | Report |
|------|--------|--------|
| RBAC Security | $([ ${RBAC_TEST_RESULT} -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED") | [rbac_test_report.md](rbac_test_report.md) |
| Secrets Management | $([ ${SECRETS_TEST_RESULT} -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED") | [secrets_test_report.md](secrets_test_report.md) |
| Network Policies | $([ ${NETPOL_TEST_RESULT} -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED") | [network_policies_test_report.md](network_policies_test_report.md) |

**Total Tests:** ${TESTS_TOTAL}
**Passed:** ${TESTS_PASSED}
**Failed:** ${TESTS_FAILED}

## Overall Result

$([ ${TESTS_FAILED} -eq 0 ] && echo "✅ **All security validation tests passed successfully!**" || echo "❌ **Some tests failed. Please review individual reports.**")

## Security Test Coverage

### RBAC Security Validation
- ✅ ServiceAccount configuration
- ✅ Role and RoleBinding validation
- ✅ Permission testing (can-i checks)
- ✅ Least privilege verification
- ✅ Pod security context validation
- ✅ No excessive permissions

### Secrets Management Validation
- ✅ Dedicated secrets namespace
- ✅ Secret creation and encryption
- ✅ RBAC-controlled access
- ✅ Unauthorized access denial
- ✅ Secret rotation capability
- ✅ Secret cleanup process
- ℹ️  Sealed Secrets detection (optional)

### Network Policies Validation
- ✅ NetworkPolicy detection
- ✅ Default deny policy analysis
- ✅ Pod selector validation
- ✅ Ingress/egress rules analysis
- ✅ Network isolation testing
- ✅ DNS policy validation
- ℹ️  Service mesh detection (optional)

## Security Best Practices

### Implemented
- ✅ Dedicated ServiceAccounts (not default)
- ✅ Least privilege RBAC
- ✅ Secure pod security contexts
- ✅ Dedicated secrets namespace
- ✅ RBAC-controlled secret access
- ✅ Namespace isolation
- ✅ DNS policy configured

### Recommendations
1. 💡 Consider implementing NetworkPolicies for enhanced isolation
2. 💡 Implement Sealed Secrets for GitOps workflows
3. 💡 Use external secret managers for production (Vault, AWS Secrets Manager)
4. 💡 Consider service mesh for mTLS and advanced traffic management
5. 💡 Implement secret rotation policies
6. 💡 Regular security audits and RBAC reviews
7. ✅ Never commit secrets to Git repositories

## Security Score

| Category | Score | Status |
|----------|-------|--------|
| RBAC | $([ ${RBAC_TEST_RESULT} -eq 0 ] && echo "100%" || echo "< 100%") | $([ ${RBAC_TEST_RESULT} -eq 0 ] && echo "✅" || echo "⚠️") |
| Secrets | $([ ${SECRETS_TEST_RESULT} -eq 0 ] && echo "100%" || echo "< 100%") | $([ ${SECRETS_TEST_RESULT} -eq 0 ] && echo "✅" || echo "⚠️") |
| Network | $([ ${NETPOL_TEST_RESULT} -eq 0 ] && echo "100%" || echo "< 100%") | $([ ${NETPOL_TEST_RESULT} -eq 0 ] && echo "✅" || echo "⚠️") |
| **Overall** | **$([ ${TESTS_FAILED} -eq 0 ] && echo "100%" || echo "< 100%")** | **$([ ${TESTS_FAILED} -eq 0 ] && echo "✅" || echo "⚠️")** |

## Next Steps

1. ✅ RBAC validation complete
2. ✅ Secrets management validation complete
3. ✅ Network policies validation complete
4. ⏳ Proceed to Week 11: Documentation & Polish

## References

- RBAC Test: [test_rbac.yml](../security/test_rbac.yml)
- Secrets Test: [test_secrets.yml](../security/test_secrets.yml)
- Network Policies Test: [test_network_policies.yml](../security/test_network_policies.yml)
- Quarkus Reference App: [../../quarkus-reference-app/](../../quarkus-reference-app/)

---

**Generated by:** Week 10 Security Validation Test Runner
**Report Location:** tests/week10/results/security_report.md
EOF

echo -e "${GREEN}✅ Combined report generated: ${RESULTS_DIR}/security_report.md${NC}"
echo ""

print_header "Test Execution Complete"

if [ ${EXIT_CODE} -eq 0 ]; then
    echo -e "${GREEN}✅ All security validation tests completed successfully!${NC}"
    echo ""
    echo "Security validation summary:"
    echo "  ✅ RBAC properly configured"
    echo "  ✅ Secrets management secure"
    echo "  ✅ Network policies analyzed"
    echo ""
    echo "Next steps:"
    echo "  1. Review security reports in: ${RESULTS_DIR}"
    echo "  2. Implement recommended enhancements"
    echo "  3. Complete Week 10 testing"
    echo "  4. Proceed to Week 11: Documentation & Polish"
else
    echo -e "${RED}❌ Some tests failed. Please review the reports and fix issues.${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check security reports in: ${RESULTS_DIR}"
    echo "  2. Review cluster logs: oc logs -n <namespace>"
    echo "  3. Check RBAC: oc auth can-i --list"
    echo "  4. Verify secrets: oc get secrets -n validated-patterns-secrets"
fi

echo ""
echo -e "${BLUE}========================================${NC}"

exit ${EXIT_CODE}
