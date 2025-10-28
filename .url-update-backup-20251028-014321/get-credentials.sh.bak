#!/bin/bash
# Retrieve Gitea credentials from deployed instance

set -euo pipefail

# Configuration
GITEA_NAMESPACE="${1:-gitea}"
GITEA_INSTANCE_NAME="${2:-gitea-with-admin}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if logged in
if ! oc whoami &>/dev/null; then
    echo "Error: Not logged into OpenShift. Please run 'oc login' first."
    exit 1
fi

# Check if Gitea instance exists
if ! oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" &>/dev/null; then
    echo "Error: Gitea instance '${GITEA_INSTANCE_NAME}' not found in namespace '${GITEA_NAMESPACE}'"
    exit 1
fi

log_info "Retrieving Gitea credentials from ${GITEA_NAMESPACE}/${GITEA_INSTANCE_NAME}..."
echo

# Get Gitea CR status
GITEA_URL=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
    -o jsonpath='{.status.giteaRoute}')
ADMIN_USER=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
    -o jsonpath='{.spec.giteaAdminUser}')
ADMIN_PASSWORD=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
    -o jsonpath='{.status.adminPassword}')
USER_PASSWORD=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
    -o jsonpath='{.status.userPassword}')
USER_FORMAT=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
    -o jsonpath='{.spec.giteaGenerateUserFormat}')
USER_NUMBER=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
    -o jsonpath='{.spec.giteaUserNumber}')

# Display credentials
echo "=========================================="
echo "Gitea Credentials"
echo "=========================================="
echo
echo "URL:             ${GITEA_URL}"
echo "Admin User:      ${ADMIN_USER}"
echo "Admin Password:  ${ADMIN_PASSWORD}"
echo

if [ -n "${USER_FORMAT}" ] && [ "${USER_NUMBER}" -gt 0 ]; then
    echo "Lab Users:       ${USER_FORMAT}-0 to ${USER_FORMAT}-$((USER_NUMBER - 1))"
    echo "Lab Password:    ${USER_PASSWORD}"
    echo
fi

echo "=========================================="
echo

# Test connection
log_info "Testing connection to Gitea..."
if curl -k -s "${GITEA_URL}/api/v1/version" >/dev/null 2>&1; then
    VERSION=$(curl -k -s "${GITEA_URL}/api/v1/version" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    log_info "Gitea is accessible! Version: ${VERSION}"
else
    log_warn "Could not connect to Gitea API. The instance may still be starting up."
fi

echo
log_info "To open Gitea in your browser, run:"
echo "  xdg-open '${GITEA_URL}' || open '${GITEA_URL}'"
