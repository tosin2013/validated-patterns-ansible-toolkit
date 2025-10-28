#!/bin/bash
# Automated cleanup script for Validated Patterns deployment
# Use this before running integration tests

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
echo -e "${BLUE}Validated Patterns Cleanup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

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

echo -e "${GREEN}✅ Connected to cluster${NC}"
echo ""

# Display current resources
echo -e "${YELLOW}Current Validated Patterns resources:${NC}"
echo ""

echo -e "${BLUE}Pattern CRs:${NC}"
oc get pattern -n openshift-operators 2>/dev/null || echo "  None found"
echo ""

echo -e "${BLUE}ArgoCD Applications:${NC}"
oc get applications -n openshift-gitops 2>/dev/null || echo "  None found"
echo ""

echo -e "${BLUE}Application Namespaces:${NC}"
for ns in validated-patterns quarkus-app-dev quarkus-app-prod; do
    if oc get namespace "$ns" &>/dev/null; then
        echo "  ✓ $ns"
    fi
done
echo ""

# Confirm cleanup
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}⚠️  WARNING: This will remove:${NC}"
echo -e "${YELLOW}  - Pattern Custom Resources${NC}"
echo -e "${YELLOW}  - ArgoCD Applications${NC}"
echo -e "${YELLOW}  - Application Namespaces${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

read -p "Continue with cleanup? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Cleanup cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Starting cleanup...${NC}"
echo ""

# Delete ArgoCD applications
echo -e "${YELLOW}Deleting ArgoCD applications...${NC}"
if oc get applications -n openshift-gitops &>/dev/null; then
    oc delete applications --all -n openshift-gitops --wait=true --timeout=5m 2>/dev/null || true
    echo -e "${GREEN}✅ ArgoCD applications deleted${NC}"
else
    echo -e "${GREEN}✅ No ArgoCD applications found${NC}"
fi
echo ""

# Delete Pattern CR
echo -e "${YELLOW}Deleting Pattern CR...${NC}"
if oc get pattern validated-patterns-ansible-toolkit -n openshift-operators &>/dev/null; then
    oc delete pattern validated-patterns-ansible-toolkit -n openshift-operators --wait=true --timeout=5m 2>/dev/null || true
    echo -e "${GREEN}✅ Pattern CR deleted${NC}"
else
    echo -e "${GREEN}✅ No Pattern CR found${NC}"
fi
echo ""

# Delete application namespaces
echo -e "${YELLOW}Deleting application namespaces...${NC}"
for ns in validated-patterns quarkus-app-dev quarkus-app-prod; do
    if oc get namespace "$ns" &>/dev/null; then
        echo "  Deleting $ns..."
        oc delete namespace "$ns" --wait=false 2>/dev/null || true
    fi
done
echo -e "${GREEN}✅ Application namespaces deletion initiated${NC}"
echo ""

# Wait for namespaces to be deleted
echo -e "${YELLOW}Waiting for namespaces to be deleted (max 5 minutes)...${NC}"
for i in {1..30}; do
    REMAINING=0
    for ns in validated-patterns quarkus-app-dev quarkus-app-prod; do
        if oc get namespace "$ns" &>/dev/null; then
            REMAINING=$((REMAINING + 1))
        fi
    done

    if [ $REMAINING -eq 0 ]; then
        echo -e "${GREEN}✅ All namespaces deleted${NC}"
        break
    fi

    echo "  Waiting... ($REMAINING namespaces remaining)"
    sleep 10
done
echo ""

# Optional: Delete GitOps namespace
echo -e "${YELLOW}========================================${NC}"
read -p "Delete GitOps namespace (openshift-gitops)? This will remove ArgoCD. (yes/no): " DELETE_GITOPS
if [ "$DELETE_GITOPS" = "yes" ]; then
    echo -e "${YELLOW}Deleting GitOps namespace...${NC}"
    oc delete namespace openshift-gitops --wait=false 2>/dev/null || true
    echo -e "${GREEN}✅ GitOps namespace deletion initiated${NC}"
else
    echo -e "${BLUE}ℹ️  GitOps namespace retained${NC}"
fi
echo ""

# Optional: Uninstall VP Operator
echo -e "${YELLOW}========================================${NC}"
read -p "Uninstall Validated Patterns Operator? (yes/no): " UNINSTALL_OPERATOR
if [ "$UNINSTALL_OPERATOR" = "yes" ]; then
    echo -e "${YELLOW}Uninstalling VP Operator...${NC}"

    # Delete subscription
    if oc get subscription patterns-operator -n openshift-operators &>/dev/null; then
        oc delete subscription patterns-operator -n openshift-operators 2>/dev/null || true
        echo "  ✓ Subscription deleted"
    fi

    # Delete CSV
    CSV_NAME=$(oc get csv -n openshift-operators | grep patterns-operator | awk '{print $1}' | head -n 1)
    if [ -n "$CSV_NAME" ]; then
        oc delete csv "$CSV_NAME" -n openshift-operators 2>/dev/null || true
        echo "  ✓ CSV deleted"
    fi

    echo -e "${GREEN}✅ VP Operator uninstalled${NC}"
else
    echo -e "${BLUE}ℹ️  VP Operator retained${NC}"
fi
echo ""

# Display final status
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${BLUE}Remaining resources:${NC}"
echo ""

echo -e "${BLUE}Pattern CRs:${NC}"
oc get pattern -n openshift-operators 2>/dev/null || echo "  None"
echo ""

echo -e "${BLUE}ArgoCD Applications:${NC}"
oc get applications -n openshift-gitops 2>/dev/null || echo "  None"
echo ""

echo -e "${BLUE}Application Namespaces:${NC}"
FOUND_NS=false
for ns in validated-patterns quarkus-app-dev quarkus-app-prod; do
    if oc get namespace "$ns" &>/dev/null; then
        echo "  ✓ $ns (still terminating)"
        FOUND_NS=true
    fi
done
if [ "$FOUND_NS" = false ]; then
    echo "  None"
fi
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cluster is ready for fresh deployment!${NC}"
echo -e "${GREEN}========================================${NC}"
