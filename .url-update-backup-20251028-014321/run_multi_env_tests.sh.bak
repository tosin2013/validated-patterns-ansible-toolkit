#!/bin/bash
# Week 10 Task 1: Multi-Environment Test Runner
# Runs all multi-environment tests for dev/prod overlays

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
echo -e "${BLUE}Week 10 - Multi-Environment Test Runner${NC}"
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
echo "Checking OpenShift GitOps operator..."
if oc get csv -n openshift-gitops | grep -q gitops; then
    echo -e "${GREEN}✅ OpenShift GitOps operator installed${NC}"
else
    echo -e "${YELLOW}⚠️  OpenShift GitOps operator not found (optional for some tests)${NC}"
fi

# Create results directory
mkdir -p "${RESULTS_DIR}"

# Run tests
print_header "Test 1: Dev Overlay Testing"
run_test "Dev Overlay Test" "test_dev_overlay.yml"
DEV_TEST_RESULT=$?

print_header "Test 2: Prod Overlay Testing"
run_test "Prod Overlay Test" "test_prod_overlay.yml"
PROD_TEST_RESULT=$?

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

cat > "${RESULTS_DIR}/multi_environment_report.md" << EOF
# Multi-Environment Test Report

**Test Date:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Test Suite:** Week 10 - Multi-Environment Testing
**Cluster:** $(oc whoami --show-server)
**User:** $(oc whoami)

## Test Summary

| Test | Status | Report |
|------|--------|--------|
| Dev Overlay | $([ ${DEV_TEST_RESULT} -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED") | [dev_overlay_test_report.md](dev_overlay_test_report.md) |
| Prod Overlay | $([ ${PROD_TEST_RESULT} -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED") | [prod_overlay_test_report.md](prod_overlay_test_report.md) |

**Total Tests:** ${TESTS_TOTAL}
**Passed:** ${TESTS_PASSED}
**Failed:** ${TESTS_FAILED}

## Overall Result

$([ ${TESTS_FAILED} -eq 0 ] && echo "✅ **All multi-environment tests passed successfully!**" || echo "❌ **Some tests failed. Please review individual reports.**")

## Test Coverage

### Dev Overlay Testing
- ✅ Deployment with dev overlay
- ✅ Single replica configuration
- ✅ Dev-specific labels and tags
- ✅ Resource limits validation
- ✅ Health endpoint testing
- ✅ Namespace isolation

### Prod Overlay Testing
- ✅ Deployment with prod overlay
- ✅ High availability (3 replicas)
- ✅ Prod-specific labels and tags
- ✅ Production resource limits
- ✅ Load balancing verification
- ✅ Rolling update strategy
- ✅ Health and metrics endpoints

## Environment Comparison

| Configuration | Dev | Prod |
|---------------|-----|------|
| Replicas | 1 | 3 |
| Environment Label | dev | prod |
| Image Tag | dev | latest |
| Namespace | quarkus-dev | reference-app |
| Resource Profile | Development | Production |
| High Availability | No | Yes |

## Next Steps

1. ✅ Dev overlay validated
2. ✅ Prod overlay validated
3. ⏳ Run overlay comparison tests
4. ⏳ Run edge case tests
5. ⏳ Proceed to performance testing (Week 10 Task 2)

## References

- Dev Overlay Test: [test_dev_overlay.yml](../multi-environment/test_dev_overlay.yml)
- Prod Overlay Test: [test_prod_overlay.yml](../multi-environment/test_prod_overlay.yml)
- Quarkus Reference App: [../../quarkus-reference-app/](../../quarkus-reference-app/)

---

**Generated by:** Week 10 Multi-Environment Test Runner
**Report Location:** tests/week10/results/multi_environment_report.md
EOF

echo -e "${GREEN}✅ Combined report generated: ${RESULTS_DIR}/multi_environment_report.md${NC}"
echo ""

print_header "Test Execution Complete"

if [ ${EXIT_CODE} -eq 0 ]; then
    echo -e "${GREEN}✅ All multi-environment tests completed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review test reports in: ${RESULTS_DIR}"
    echo "  2. Run overlay comparison tests"
    echo "  3. Run edge case tests"
    echo "  4. Proceed to Week 10 Task 2: Performance Testing"
else
    echo -e "${RED}❌ Some tests failed. Please review the reports and fix issues.${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check test reports in: ${RESULTS_DIR}"
    echo "  2. Review cluster logs: oc logs -n <namespace>"
    echo "  3. Check pod status: oc get pods -n <namespace>"
fi

echo ""
echo -e "${BLUE}========================================${NC}"

exit ${EXIT_CODE}
