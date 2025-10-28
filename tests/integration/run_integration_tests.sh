#!/bin/bash
# End-to-End Integration Test Runner
# Week 9 Task 3: Integration Testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default verbosity
VERBOSE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v)
            VERBOSE="-v"
            shift
            ;;
        -vv)
            VERBOSE="-vv"
            shift
            ;;
        -vvv)
            VERBOSE="-vvv"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-v|-vv|-vvv]"
            echo ""
            echo "Options:"
            echo "  -v      Verbose output (ansible -v)"
            echo "  -vv     More verbose output (ansible -vv)"
            echo "  -vvv    Very verbose output (ansible -vvv)"
            echo "  -h      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h for help"
            exit 1
            ;;
    esac
done

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}End-to-End Integration Test${NC}"
echo -e "${BLUE}Week 9 Task 3${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check if oc is available
if ! command -v oc &> /dev/null; then
    echo -e "${RED}❌ Error: 'oc' command not found${NC}"
    exit 1
fi

# Check if logged into cluster
if ! oc whoami &> /dev/null; then
    echo -e "${RED}❌ Error: Not logged into OpenShift cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✅ OpenShift CLI available and logged in${NC}"

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}❌ Error: 'ansible-playbook' command not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Ansible available${NC}"

# Check if kubernetes.core collection is installed
if ! ansible-galaxy collection list | grep -q "kubernetes.core"; then
    echo -e "${YELLOW}⚠️  kubernetes.core collection not found, installing...${NC}"
    ansible-galaxy collection install kubernetes.core
fi

echo -e "${GREEN}✅ kubernetes.core collection available${NC}"

# Display cluster information
echo ""
echo -e "${BLUE}Cluster Information:${NC}"
oc version
echo ""
oc cluster-info | head -n 1
echo ""

# Check if values files exist
if [ ! -f "values-global.yaml" ]; then
    echo -e "${RED}❌ Error: values-global.yaml not found${NC}"
    exit 1
fi

if [ ! -f "values-hub.yaml" ]; then
    echo -e "${RED}❌ Error: values-hub.yaml not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Values files found${NC}"
echo ""

# Check for existing deployment
echo -e "${YELLOW}Checking for existing deployment...${NC}"
if oc get pattern validated-patterns-ansible-toolkit -n openshift-operators &>/dev/null; then
    echo -e "${YELLOW}⚠️  WARNING: Pattern CR already exists!${NC}"
    echo ""
    echo -e "${YELLOW}This may affect test results.${NC}"
    echo -e "${YELLOW}It's recommended to run cleanup first.${NC}"
    echo ""
    read -p "Do you want to run cleanup now? (yes/no): " RUN_CLEANUP

    if [ "$RUN_CLEANUP" = "yes" ]; then
        echo ""
        echo -e "${BLUE}Running cleanup...${NC}"
        cd cleanup
        ./cleanup.sh
        cd ..
        echo ""
        echo -e "${GREEN}✅ Cleanup complete${NC}"
        echo ""
        sleep 5
    else
        echo ""
        echo -e "${YELLOW}Proceeding without cleanup...${NC}"
        echo ""
    fi
else
    echo -e "${GREEN}✅ No existing deployment found${NC}"
fi
echo ""

# Create results directory
mkdir -p results

# Run the integration test
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running End-to-End Integration Test${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ -n "$VERBOSE" ]; then
    echo -e "${YELLOW}Running with verbosity: $VERBOSE${NC}"
    echo ""
fi

START_TIME=$(date +%s)

# Run with optional verbose output
if ansible-playbook playbooks/test_end_to_end.yml $VERBOSE; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ Integration Test Completed Successfully${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${GREEN}Total Duration: ${DURATION}s${NC}"
    echo ""

    # Display test report if it exists
    if [ -f "results/end_to_end_report.md" ]; then
        echo -e "${BLUE}Test Report:${NC}"
        echo ""
        cat results/end_to_end_report.md
        echo ""
    fi

    echo -e "${GREEN}Test report saved to: results/end_to_end_report.md${NC}"
    echo ""

    # Display ArgoCD access information
    ARGOCD_URL=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not found")
    if [ "$ARGOCD_URL" != "Not found" ]; then
        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}ArgoCD Access Information${NC}"
        echo -e "${BLUE}========================================${NC}"
        echo -e "${GREEN}URL: https://${ARGOCD_URL}${NC}"
        echo -e "${GREEN}Username: admin${NC}"
        echo ""
        echo -e "${YELLOW}Get password:${NC}"
        echo "oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d"
        echo ""
    fi

    exit 0
else
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}❌ Integration Test Failed${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${RED}Duration: ${DURATION}s${NC}"
    echo ""
    echo -e "${YELLOW}Check the output above for error details${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "1. Check operator logs: oc logs -n openshift-operators -l name=patterns-operator"
    echo "2. Check Pattern CR: oc describe pattern validated-patterns-ansible-toolkit -n openshift-operators"
    echo "3. Check ArgoCD: oc get pods -n openshift-gitops"
    echo "4. Run cleanup and try again: cd cleanup && ./cleanup.sh"
    echo ""
    exit 1
fi
