#!/bin/bash
# Deploy Gitea using the Red Hat GPTE Gitea Operator
# Based on: https://github.com/tosin2013/openshift-demos/blob/master/quick-scripts/deploy-gitea.sh

set -euo pipefail

# Configuration
GITEA_OPERATOR_REPO="${GITEA_OPERATOR_REPO:-https://github.com/rhpds/gitea-operator}"
GITEA_OPERATOR_PATH="${GITEA_OPERATOR_PATH:-OLMDeploy}"
GITEA_OPERATOR_NAMESPACE="${GITEA_OPERATOR_NAMESPACE:-gitea-operator}"
GITEA_NAMESPACE="${GITEA_NAMESPACE:-gitea}"
GITEA_INSTANCE_NAME="${GITEA_INSTANCE_NAME:-gitea-with-admin}"

# Admin configuration
GITEA_ADMIN_USER="${GITEA_ADMIN_USER:-opentlc-mgr}"
GITEA_ADMIN_EMAIL="${GITEA_ADMIN_EMAIL:-opentlc-mgr@redhat.com}"
GITEA_ADMIN_PASSWORD_LENGTH="${GITEA_ADMIN_PASSWORD_LENGTH:-32}"

# User configuration (for training scenarios)
GITEA_CREATE_USERS="${GITEA_CREATE_USERS:-true}"
GITEA_USER_FORMAT="${GITEA_USER_FORMAT:-lab-user}"
GITEA_USER_NUMBER="${GITEA_USER_NUMBER:-1}"
GITEA_USER_PASSWORD_LENGTH="${GITEA_USER_PASSWORD_LENGTH:-16}"

# SSL configuration
GITEA_SSL="${GITEA_SSL:-true}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

wait_for_pod() {
    local pod_name=$1
    local namespace=$2

    log_info "Waiting for pod ${pod_name} in namespace ${namespace}..."

    local max_attempts=60
    local attempt=0

    while [[ $(oc get pods "${pod_name}" -n "${namespace}" \
        -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' 2>/dev/null) != "True" ]]; do

        attempt=$((attempt + 1))
        if [ $attempt -ge $max_attempts ]; then
            log_error "Timeout waiting for pod ${pod_name}"
            return 1
        fi

        echo -n "."
        sleep 2
    done

    echo
    log_info "Pod ${pod_name} is ready!"
}

check_oc_login() {
    if ! oc whoami &>/dev/null; then
        log_error "Not logged into OpenShift. Please run 'oc login' first."
        exit 1
    fi

    log_info "Logged in as: $(oc whoami)"
}

deploy_operator() {
    log_info "Checking if Gitea Operator is already deployed..."

    if oc get namespace "${GITEA_OPERATOR_NAMESPACE}" &>/dev/null; then
        log_warn "Gitea Operator namespace already exists. Skipping operator deployment."
        return 0
    fi

    log_info "Deploying Gitea Operator from ${GITEA_OPERATOR_REPO}..."

    if ! oc apply -k "${GITEA_OPERATOR_REPO}/${GITEA_OPERATOR_PATH}"; then
        log_error "Failed to deploy Gitea Operator"
        exit 1
    fi

    log_info "Waiting for operator deployment (60 seconds)..."
    sleep 60

    # Get operator pod name
    local operator_pod
    operator_pod=$(oc get pods -n "${GITEA_OPERATOR_NAMESPACE}" \
        --no-headers \
        | grep gitea-operator-controller-manager- \
        | awk '{print $1}' \
        | head -n 1)

    if [ -z "${operator_pod}" ]; then
        log_error "Could not find Gitea Operator pod"
        exit 1
    fi

    wait_for_pod "${operator_pod}" "${GITEA_OPERATOR_NAMESPACE}"
}

create_gitea_instance() {
    log_info "Creating Gitea namespace: ${GITEA_NAMESPACE}"

    if ! oc get namespace "${GITEA_NAMESPACE}" &>/dev/null; then
        oc new-project "${GITEA_NAMESPACE}"
    else
        log_warn "Namespace ${GITEA_NAMESPACE} already exists"
    fi

    log_info "Creating Gitea instance: ${GITEA_INSTANCE_NAME}"

    # Create Gitea CR
    cat <<EOF | oc apply -f -
apiVersion: pfe.rhpds.com/v1
kind: Gitea
metadata:
  name: ${GITEA_INSTANCE_NAME}
  namespace: ${GITEA_NAMESPACE}
spec:
  giteaSsl: ${GITEA_SSL}
  giteaAdminUser: ${GITEA_ADMIN_USER}
  giteaAdminPassword: ""
  giteaAdminPasswordLength: ${GITEA_ADMIN_PASSWORD_LENGTH}
  giteaAdminEmail: ${GITEA_ADMIN_EMAIL}
  giteaCreateUsers: ${GITEA_CREATE_USERS}
  giteaGenerateUserFormat: ${GITEA_USER_FORMAT}
  giteaUserNumber: ${GITEA_USER_NUMBER}
  giteaUserPasswordLength: ${GITEA_USER_PASSWORD_LENGTH}
EOF

    log_info "Waiting for Gitea instance to be ready..."

    local max_attempts=60
    local attempt=0

    while true; do
        local status
        status=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
            -o jsonpath='{.status.conditions[?(@.type=="Successful")].status}' 2>/dev/null || echo "")

        if [ "${status}" = "True" ]; then
            log_info "Gitea instance is ready!"
            break
        fi

        attempt=$((attempt + 1))
        if [ $attempt -ge $max_attempts ]; then
            log_error "Timeout waiting for Gitea instance"
            exit 1
        fi

        echo -n "."
        sleep 5
    done

    echo
}

display_credentials() {
    log_info "Retrieving Gitea credentials..."

    local gitea_url
    local admin_password
    local user_password

    gitea_url=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
        -o jsonpath='{.status.giteaRoute}')
    admin_password=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
        -o jsonpath='{.status.adminPassword}')
    user_password=$(oc get gitea "${GITEA_INSTANCE_NAME}" -n "${GITEA_NAMESPACE}" \
        -o jsonpath='{.status.userPassword}')

    echo
    echo "=========================================="
    echo "Gitea Deployment Complete!"
    echo "=========================================="
    echo
    echo "Gitea URL:       ${gitea_url}"
    echo "Admin User:      ${GITEA_ADMIN_USER}"
    echo "Admin Password:  ${admin_password}"
    echo

    if [ "${GITEA_CREATE_USERS}" = "true" ]; then
        echo "Lab Users:       ${GITEA_USER_FORMAT}-0 to ${GITEA_USER_FORMAT}-$((GITEA_USER_NUMBER - 1))"
        echo "Lab Password:    ${user_password}"
        echo
    fi

    echo "=========================================="
    echo

    # Save credentials to file
    local creds_file="gitea-credentials.txt"
    cat > "${creds_file}" <<EOF
Gitea Credentials
=================

URL: ${gitea_url}
Admin User: ${GITEA_ADMIN_USER}
Admin Password: ${admin_password}

Lab Users: ${GITEA_USER_FORMAT}-0 to ${GITEA_USER_FORMAT}-$((GITEA_USER_NUMBER - 1))
Lab Password: ${user_password}

Generated: $(date)
EOF

    log_info "Credentials saved to: ${creds_file}"
}

# Main execution
main() {
    log_info "Starting Gitea deployment..."
    echo

    check_oc_login
    deploy_operator
    create_gitea_instance
    display_credentials

    log_info "Gitea deployment completed successfully!"
}

# Run main function
main "$@"
