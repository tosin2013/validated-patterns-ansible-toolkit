#!/bin/bash
# Week 9 Task 2: VP Operator Role Test Runner
# This script runs the comprehensive test suite for the validated_patterns_operator role

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Week 9 Task 2: VP Operator Role Testing${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check if oc is available
if ! command -v oc &> /dev/null; then
    echo -e "${RED}❌ Error: 'oc' command not found${NC}"
    echo "Please install OpenShift CLI and ensure you're logged in"
    exit 1
fi

# Check if logged into cluster
if ! oc whoami &> /dev/null; then
    echo -e "${RED}❌ Error: Not logged into OpenShift cluster${NC}"
    echo "Please run: oc login <cluster-url>"
    exit 1
fi

echo -e "${GREEN}✅ OpenShift CLI available and logged in${NC}"

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}❌ Error: 'ansible-playbook' command not found${NC}"
    echo "Please install Ansible"
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

# Create results directory
mkdir -p results

# Run the test playbook
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running Test Playbook${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Run with verbose output
if ansible-playbook test_operator.yml -v; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ Tests Completed Successfully${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # Display test report if it exists
    if [ -f "results/operator_test_report.md" ]; then
        echo -e "${BLUE}Test Report:${NC}"
        echo ""
        cat results/operator_test_report.md
        echo ""
    fi

    echo -e "${GREEN}Test report saved to: results/operator_test_report.md${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}❌ Tests Failed${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Check the output above for error details${NC}"
    exit 1
fi
