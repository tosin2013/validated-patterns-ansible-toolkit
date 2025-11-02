# Ansible Automation Platform - Makefile for Execution Environments
# Original version found on ansiblejunky @ https://github.com/ansiblejunky/ansible-execution-environment

# Update defaults
TARGET_TAG ?= v5
CONTAINER_ENGINE ?= podman
VERBOSITY ?= 3
SOURCE_HUB ?= registry.redhat.io
SOURCE_TOKEN ?= ANSIBLE_HUB_TOKEN
#SOURCE_USERNAME ?= jwadleig
TARGET_HUB ?= quay.io
#TARGET_USERNAME ?= jwadleig
TARGET_NAME ?= takinosh/validated-patterns-ansible-toolkit-ee

ifndef $(SOURCE_TOKEN)
  $(error The environment variable ANSIBLE_HUB_TOKEN is undefined and required)
endif

.PHONY : header clean lint check build scan test publish list shell docs-setup docs-build docs-serve docs-test token
all: header clean lint build test publish

header:
	@echo "\n\n***************************** Ansible Automation Platform - Makefile for Execution Environments \n"

clean: # Clean temporary files, folders and images
	@echo "\n\n***************************** Cleaning... \n"
	rm -rf \
		context \
		ansible-navigator.log \
		ansible-builder.log \
		ansible-builder.bak.log \
		collections
	$(CONTAINER_ENGINE) image prune -a -f

lint: # Lint the repository with yamllint
	@echo "\n\n***************************** Linting... \n"
	yamllint .

token: # Test token
	@echo "\n\n***************************** Token... \n"
	envsubst < files/ansible.cfg.template > ./ansible.cfg
	mkdir -p collections
	ansible-galaxy collection download -r files/requirements.yml -p collections/


build: # Build the execution environment image
	@echo "\n\n***************************** Building... \n"
	$(CONTAINER_ENGINE) login $(SOURCE_HUB)
	if [ -a ansible.cfg ] ; \
	then \
		echo "Using existing ansible.cfg"; \
	else \
		envsubst < files/ansible.cfg.template > ./ansible.cfg; \
	fi;
	if [ -a ansible-builder.log ] ; \
	then \
		cp ansible-builder.log ansible-builder.bak.log ; \
	fi;
	ansible-builder introspect --sanitize --user-pip=files/requirements.txt --user-bindep=files/bindep.txt 2>&1 | tee ansible-builder.log
	ansible-builder build \
			--tag $(TARGET_NAME):$(TARGET_TAG) \
			--verbosity $(VERBOSITY) \
			--container-runtime $(CONTAINER_ENGINE) 2>&1 | tee -a ansible-builder.log

scan: # Scan image for vulnerabilities https://www.redhat.com/sysadmin/using-quayio-scanner
	@echo "\n\n***************************** Scanning... \n"
	echo "TODO:"

inspect: # Inspect built image to show information
	@echo "\n\n***************************** Inspecting... \n"
	$(CONTAINER_ENGINE) inspect $(TARGET_NAME):$(TARGET_TAG)

list: # List the built image by name:tag
	@echo "\n\n***************************** Images... \n"
	$(CONTAINER_ENGINE) images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}" --filter reference=$(TARGET_NAME):$(TARGET_TAG)

test: # Run the example playbook using the built container image
	@echo "\n\n***************************** Testing... \n"
	@echo "Verifying image exists locally:"
	$(CONTAINER_ENGINE) images $(TARGET_NAME):$(TARGET_TAG)
	ansible-navigator run \
		files/playbook.yml \
		--container-engine $(CONTAINER_ENGINE) \
		--mode stdout \
		--pull-policy never \
		--execution-environment-image $(TARGET_NAME):$(TARGET_TAG)

info: # Produce information about the published container image that can be used as the README in AAP
	@echo "\n\n***************************** Image Layers ... \n"
	$(CONTAINER_ENGINE) history --human $(TARGET_NAME):$(TARGET_TAG)
	@echo "\n\n***************************** Ansible Version ... \n"
	$(CONTAINER_ENGINE) container run -it --rm $(TARGET_NAME):$(TARGET_TAG) ansible --version
	@echo "\n\n***************************** Ansible Collections ... \n"
	$(CONTAINER_ENGINE) container run -it --rm $(TARGET_NAME):$(TARGET_TAG) ansible-galaxy collection list
	@echo "\n\n***************************** Python Modules ... \n"
	$(CONTAINER_ENGINE) container run -it --rm $(TARGET_NAME):$(TARGET_TAG) pip3 list --format freeze
	@echo "\n\n***************************** System Packages ... \n"
	$(CONTAINER_ENGINE) container run -it --rm $(TARGET_NAME):$(TARGET_TAG) rpm -qa

publish: # Publish the image with proper tags to container registry
	@echo "\n\n***************************** Publishing... \n"
	$(CONTAINER_ENGINE) login $(TARGET_HUB)
	$(CONTAINER_ENGINE) tag  \
		$(TARGET_NAME):$(TARGET_TAG) $(TARGET_NAME):latest
	$(CONTAINER_ENGINE) tag  \
		$(TARGET_NAME):$(TARGET_TAG) \
		$(TARGET_HUB)/$(TARGET_NAME):$(TARGET_TAG)
	$(CONTAINER_ENGINE) push \
		$(TARGET_HUB)/$(TARGET_NAME):$(TARGET_TAG)
	$(CONTAINER_ENGINE) pull \
		$(TARGET_HUB)/$(TARGET_NAME):$(TARGET_TAG)
	$(CONTAINER_ENGINE) tag  \
		$(TARGET_HUB)/$(TARGET_NAME):$(TARGET_TAG) \
		$(TARGET_HUB)/${TARGET_NAME}\:latest
	$(CONTAINER_ENGINE) push \
		$(TARGET_HUB)/${TARGET_NAME}:latest

shell: # Run an interactive shell in the execution environment
	$(CONTAINER_ENGINE) run -it --rm $(TARGET_NAME):$(TARGET_TAG) /bin/bash

docs-setup: # Setup MkDocs virtualenv and dependencies
	@echo "\n\n***************************** Docs Setup... \n"
	python3 -m venv .venv-docs || true
	. .venv-docs/bin/activate; pip install -r mkdocs.yml/requirements.txt

docs-build: docs-setup # Build docs locally with MkDocs
	@echo "\n\n***************************** Docs Build... \n"
	. .venv-docs/bin/activate; mkdocs build -f mkdocs.yml/mkdocs.yml

docs-serve: docs-setup # Serve docs on localhost:8000
	@echo "\n\n***************************** Docs Serve... \n"
	. .venv-docs/bin/activate; mkdocs serve -f mkdocs.yml/mkdocs.yml -a 127.0.0.1:8000

docs-test: # Build, serve, and probe the site locally
	@echo "\n\n***************************** Docs Test... \n"
	bash scripts/test-docs-local.sh

#
# Validated Patterns Deployment Targets (ADR-007)
#

.PHONY: deploy-pattern validate-pattern setup-gitea deploy-pattern-interactive list-patterns show-navigator-config pull-ee

deploy-pattern: # Deploy a Validated Pattern using ansible-navigator
	@if [ -z "$(PATTERN_NAME)" ]; then \
		echo "Error: PATTERN_NAME is required"; \
		echo "Usage: make deploy-pattern PATTERN_NAME=multicloud-gitops"; \
		echo ""; \
		echo "Available patterns:"; \
		ls -1 patterns/ 2>/dev/null | grep -v README || echo "  (patterns directory not yet created)"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Deploying Pattern: $(PATTERN_NAME) \n"
	ansible-navigator run ansible/playbooks/deploy_pattern.yml \
		-e pattern_name=$(PATTERN_NAME) \
		$(EXTRA_VARS)

validate-pattern: # Validate a deployed Validated Pattern
	@if [ -z "$(PATTERN_NAME)" ]; then \
		echo "Error: PATTERN_NAME is required"; \
		echo "Usage: make validate-pattern PATTERN_NAME=multicloud-gitops"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Validating Pattern: $(PATTERN_NAME) \n"
	ansible-navigator run ansible/playbooks/validate_pattern.yml \
		-e pattern_name=$(PATTERN_NAME)

setup-gitea: # Setup Gitea development environment
	@echo "\n\n***************************** Setting up Gitea \n"
	ansible-navigator run ansible/playbooks/setup_gitea.yml

deploy-pattern-interactive: # Deploy pattern in interactive mode for debugging
	@if [ -z "$(PATTERN_NAME)" ]; then \
		echo "Error: PATTERN_NAME is required"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Deploying Pattern (Interactive): $(PATTERN_NAME) \n"
	ansible-navigator run ansible/playbooks/deploy_pattern.yml \
		-e pattern_name=$(PATTERN_NAME) \
		-m interactive \
		$(EXTRA_VARS)

list-patterns: # List available Validated Patterns
	@echo "\n\n***************************** Available Patterns \n"
	@if [ -d "patterns" ]; then \
		ls -1 patterns/ | grep -v README; \
	else \
		echo "patterns/ directory not yet created"; \
	fi

show-navigator-config: # Show effective ansible-navigator configuration
	@echo "\n\n***************************** Ansible Navigator Configuration \n"
	ansible-navigator settings --effective

pull-ee: # Pull the latest execution environment image
	@echo "\n\n***************************** Pulling EE Image \n"
	$(CONTAINER_ENGINE) pull quay.io/validated-patterns/ansible-ee:latest
	$(CONTAINER_ENGINE) tag quay.io/validated-patterns/ansible-ee:latest $(TARGET_NAME):$(TARGET_TAG)

#
# End-to-End Deployment Targets (Recommended for Users & Developers)
# Uses Ansible roles for complete pattern deployment
#

.PHONY: check-prerequisites end2end-deployment end2end-deployment-interactive end2end-cleanup end2end-help

check-prerequisites: # Validate cluster meets prerequisites (non-destructive check)
	@echo "\n\n***************************** Checking Prerequisites \n"
	ansible-navigator run \
		ansible/playbooks/test_prerequisites.yml \
		--container-engine $(CONTAINER_ENGINE) \
		--execution-environment-image $(TARGET_NAME):$(TARGET_TAG) \
		--mode stdout

end2end-deployment: check-prerequisites # Deploy complete pattern end-to-end using Ansible roles (MAIN ENTRY POINT)
	@echo "\n\n***************************** End-to-End Pattern Deployment \n"
	ansible-navigator run \
		ansible/playbooks/deploy_complete_pattern.yml \
		--container-engine $(CONTAINER_ENGINE) \
		--execution-environment-image $(TARGET_NAME):$(TARGET_TAG) \
		$(EXTRA_VARS)

end2end-deployment-interactive: check-prerequisites # Deploy pattern in interactive mode for debugging
	@echo "\n\n***************************** End-to-End Pattern Deployment (Interactive) \n"
	ansible-navigator run \
		ansible/playbooks/deploy_complete_pattern.yml \
		--container-engine $(CONTAINER_ENGINE) \
		--execution-environment-image $(TARGET_NAME):$(TARGET_TAG) \
		-m interactive \
		$(EXTRA_VARS)

end2end-cleanup: # Cleanup pattern resources (removes Pattern CR, ArgoCD apps, namespaces)
	@echo "\n\n***************************** End-to-End Cleanup \n"
	ansible-navigator run \
		ansible/playbooks/cleanup_pattern.yml \
		--container-engine $(CONTAINER_ENGINE) \
		--execution-environment-image $(TARGET_NAME):$(TARGET_TAG) \
		$(EXTRA_VARS)

end2end-help: # Show end-to-end deployment workflow and available options
	@echo "\n\n***************************** End-to-End Deployment Workflow \n"
	@echo "============================================================================"
	@echo "RECOMMENDED WORKFLOW FOR DEVELOPERS & END-USERS"
	@echo "============================================================================"
	@echo ""
	@echo "Step 1 - Build Execution Environment:"
	@echo "  $$ make build test"
	@echo ""
	@echo "Step 2 - Check cluster prerequisites (non-destructive):"
	@echo "  $$ make check-prerequisites"
	@echo ""
	@echo "Step 3 - Deploy complete pattern using Ansible roles:"
	@echo "  $$ make end2end-deployment"
	@echo ""
	@echo "Step 4 - For interactive debugging:"
	@echo "  $$ make end2end-deployment-interactive"
	@echo ""
	@echo "Step 5 - Cleanup when done:"
	@echo "  $$ make end2end-cleanup"
	@echo ""
	@echo "============================================================================"
	@echo "DOCUMENTATION"
	@echo "============================================================================"
	@echo "  - Main playbook: ansible/playbooks/deploy_complete_pattern.yml"
	@echo "  - End-user guide: docs/END-USER-GUIDE.md"
	@echo "  - Developer guide: docs/DEVELOPER-GUIDE.md"
	@echo "  - Deployment flowchart: docs/DEPLOYMENT-DECISION-FLOWCHART.md"
	@echo ""

#
# Onboarding Targets (New & Existing Projects)
# Analyze cluster, setup development environment, initialize projects
#

.PHONY: cluster-info onboard-help onboard-new-project onboard-existing-project onboard-status gitea-create-repo gitea-push-project gitea-list-repos gitea-delete-repo release

cluster-info: # Analyze cluster and display requirements
	@echo "\n\n***************************** Cluster Information Report \n"
	@echo "OpenShift Version:"
	oc version | grep openshift || echo "  Not an OpenShift cluster"
	@echo ""
	@echo "Kubernetes Version:"
	oc version | grep -i kubernetes || echo "  Not available"
	@echo ""
	@echo "Available Operators:"
	oc get operators 2>/dev/null | wc -l || echo "  No operators found"
	@echo ""
	@echo "Cluster Nodes:"
	oc get nodes -o wide 2>/dev/null | tail -n +2 | wc -l || echo "  No nodes found"
	@echo ""
	@echo "Storage Classes:"
	oc get storageclass 2>/dev/null | tail -n +2 | wc -l || echo "  No storage classes found"
	@echo ""
	@echo "For more details, check ONBOARDING.md"
	@echo ""

onboard-help: # Show onboarding guide and options
	@echo "\n\n***************************** Onboarding Guide \n"
	@echo "Choose your path:"
	@echo ""
	@echo "1. NEW PROJECT:"
	@echo "   $$ make onboard-new-project PROJECT_NAME=my-pattern"
	@echo "   Creates new project structure and deploys Gitea"
	@echo ""
	@echo "2. EXISTING PROJECT:"
	@echo "   $$ make onboard-existing-project PROJECT_NAME=my-pattern"
	@echo "   Onboards existing project into toolkit"
	@echo ""
	@echo "3. CHECK STATUS:"
	@echo "   $$ make onboard-status PROJECT_NAME=my-pattern"
	@echo "   Show onboarding status"
	@echo ""
	@echo "4. MANAGE GITEA:"
	@echo "   $$ make gitea-list-repos"
	@echo "   $$ make gitea-create-repo REPO_NAME=name"
	@echo "   $$ make gitea-push-project PROJECT_PATH=. REPO_NAME=name"
	@echo "   $$ make gitea-delete-repo REPO_NAME=name"
	@echo ""
	@echo "5. RELEASE:"
	@echo "   $$ make release VERSION=v1.0.0"
	@echo "   Push release to GitHub"
	@echo ""
	@echo "For complete guide, see: ONBOARDING.md"
	@echo ""

onboard-new-project: # Create and initialize new project (requires PROJECT_NAME)
	@if [ -z "$(PROJECT_NAME)" ]; then \
		echo "Error: PROJECT_NAME is required"; \
		echo "Usage: make onboard-new-project PROJECT_NAME=my-pattern"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Onboarding New Project: $(PROJECT_NAME) \n"
	@echo "Step 1: Creating project structure..."
	mkdir -p $(PROJECT_NAME)/{ansible/roles,helm/$(PROJECT_NAME),k8s,src,scripts}
	@echo "Step 2: Creating configuration files..."
	cp values-global.yaml $(PROJECT_NAME)/
	cp values-hub.yaml $(PROJECT_NAME)/
	@echo "Step 3: Creating development memory..."
	echo "# Development Memory: $(PROJECT_NAME)" > $(PROJECT_NAME)/DEVELOPMENT-MEMORY.md
	echo "Project created at: $(PROJECT_NAME)/" >> $(PROJECT_NAME)/DEVELOPMENT-MEMORY.md
	@echo "Step 4: Initialize git repository..."
	cd $(PROJECT_NAME) && git init && git add . && git commit -m "initial: project structure"
	@echo "\n✅ New project created!"
	@echo "Next steps:"
	@echo "  1. Edit $(PROJECT_NAME)/DEVELOPMENT-MEMORY.md"
	@echo "  2. Run: make setup-gitea"
	@echo "  3. Run: make gitea-push-project PROJECT_PATH=$(PROJECT_NAME) REPO_NAME=$(PROJECT_NAME)"
	@echo "  4. Run: make end2end-deployment"
	@echo ""

onboard-existing-project: # Onboard existing project (requires PROJECT_NAME)
	@if [ -z "$(PROJECT_NAME)" ]; then \
		echo "Error: PROJECT_NAME is required"; \
		echo "Usage: make onboard-existing-project PROJECT_NAME=my-pattern"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT_NAME)" ]; then \
		echo "Error: Directory $(PROJECT_NAME) not found"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Onboarding Existing Project: $(PROJECT_NAME) \n"
	@echo "Step 1: Creating .validated-patterns/ subdirectory..."
	mkdir -p $(PROJECT_NAME)/.validated-patterns/{ansible/roles,helm/$(PROJECT_NAME),k8s,scripts}
	@echo "Step 2: Copying toolkit files..."
	cp values-global.yaml $(PROJECT_NAME)/.validated-patterns/
	cp values-hub.yaml $(PROJECT_NAME)/.validated-patterns/
	@echo "Step 3: Creating development memory..."
	echo "# Development Memory: $(PROJECT_NAME)" > $(PROJECT_NAME)/.validated-patterns/DEVELOPMENT-MEMORY.md
	echo "Onboarded: $(shell date)" >> $(PROJECT_NAME)/.validated-patterns/DEVELOPMENT-MEMORY.md
	@echo "Step 4: Creating integration guide..."
	echo "# Integration Guide: $(PROJECT_NAME)" > $(PROJECT_NAME)/.validated-patterns/INTEGRATION-GUIDE.md
	echo "Toolkit files are isolated in .validated-patterns/" >> $(PROJECT_NAME)/.validated-patterns/INTEGRATION-GUIDE.md
	echo "Your existing project files are untouched." >> $(PROJECT_NAME)/.validated-patterns/INTEGRATION-GUIDE.md
	@echo "Step 5: Initialize git if needed..."
	@if [ ! -d "$(PROJECT_NAME)/.git" ]; then \
		cd $(PROJECT_NAME) && git init && git add . && git commit -m "initial: project structure"; \
	else \
		cd $(PROJECT_NAME) && git add .validated-patterns && git commit -m "chore: add validated-patterns integration" || true; \
	fi
	@echo "\n✅ Project onboarded!"
	@echo "Toolkit files location: $(PROJECT_NAME)/.validated-patterns/"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Review integration guide:"
	@echo "     $$ cat $(PROJECT_NAME)/.validated-patterns/INTEGRATION-GUIDE.md"
	@echo ""
	@echo "  2. (Optional) Copy toolkit files to your project:"
	@echo "     $$ cp -r $(PROJECT_NAME)/.validated-patterns/helm/$(PROJECT_NAME) $(PROJECT_NAME)/helm/"
	@echo "     $$ cp -r $(PROJECT_NAME)/.validated-patterns/ansible $(PROJECT_NAME)/"
	@echo ""
	@echo "  3. Deploy to cluster:"
	@echo "     $$ cd $(PROJECT_NAME)/.validated-patterns && make end2end-deployment"
	@echo ""
	@echo "  4. Edit development memory:"
	@echo "     $$ vim $(PROJECT_NAME)/.validated-patterns/DEVELOPMENT-MEMORY.md"
	@echo ""

onboard-status: # Show onboarding status (requires PROJECT_NAME)
	@if [ -z "$(PROJECT_NAME)" ]; then \
		echo "Error: PROJECT_NAME is required"; \
		echo "Usage: make onboard-status PROJECT_NAME=my-pattern"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT_NAME)" ]; then \
		echo "Error: Directory $(PROJECT_NAME) not found"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Onboarding Status: $(PROJECT_NAME) \n"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Location: $(shell pwd)/$(PROJECT_NAME)"
	@echo ""
	@if [ -d "$(PROJECT_NAME)/.validated-patterns" ]; then \
		echo "✓ Toolkit Integration (.validated-patterns/)"; \
	else \
		echo "✗ Toolkit Integration NOT FOUND"; \
	fi
	@echo ""
	@echo "Toolkit Files:"
	@ls -la $(PROJECT_NAME)/.validated-patterns/ 2>/dev/null || echo "  .validated-patterns/ not found"
	@echo ""
	@echo "Development Memory:"
	@if [ -f "$(PROJECT_NAME)/.validated-patterns/DEVELOPMENT-MEMORY.md" ]; then \
		echo "  ✓ Found at: $(PROJECT_NAME)/.validated-patterns/DEVELOPMENT-MEMORY.md"; \
	else \
		echo "  ✗ Not found"; \
	fi
	@echo ""
	@echo "Integration Guide:"
	@if [ -f "$(PROJECT_NAME)/.validated-patterns/INTEGRATION-GUIDE.md" ]; then \
		echo "  ✓ Found at: $(PROJECT_NAME)/.validated-patterns/INTEGRATION-GUIDE.md"; \
	else \
		echo "  ✗ Not found"; \
	fi
	@echo ""
	@echo "Next Steps:"
	@echo "  1. Review integration options:"
	@echo "     $$ cat $(PROJECT_NAME)/.validated-patterns/INTEGRATION-GUIDE.md"
	@echo ""
	@echo "  2. Deploy pattern to cluster:"
	@echo "     $$ cd $(PROJECT_NAME)/.validated-patterns && make end2end-deployment"
	@echo ""
	@echo "  3. (Optional) Copy files to main project:"
	@echo "     $$ cp -r $(PROJECT_NAME)/.validated-patterns/helm/* $(PROJECT_NAME)/helm/"
	@echo ""

gitea-create-repo: # Create repository in Gitea (requires REPO_NAME)
	@if [ -z "$(REPO_NAME)" ]; then \
		echo "Error: REPO_NAME is required"; \
		echo "Usage: make gitea-create-repo REPO_NAME=my-repo"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Creating Gitea Repository: $(REPO_NAME) \n"
	@echo "Repository $(REPO_NAME) would be created in Gitea"
	@echo "Implementation requires Gitea API integration"
	@echo ""

gitea-push-project: # Push project to Gitea (requires PROJECT_PATH and REPO_NAME)
	@if [ -z "$(PROJECT_PATH)" ] || [ -z "$(REPO_NAME)" ]; then \
		echo "Error: PROJECT_PATH and REPO_NAME are required"; \
		echo "Usage: make gitea-push-project PROJECT_PATH=. REPO_NAME=my-repo"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Pushing Project to Gitea: $(REPO_NAME) \n"
	@echo "Project: $(PROJECT_PATH)"
	@echo "Repository: $(REPO_NAME)"
	@echo ""
	@echo "Instructions:"
	@echo "1. Get Gitea URL: oc get routes -n gitea"
	@echo "2. Add Gitea remote: git remote add gitea <GITEA_URL>/$(REPO_NAME).git"
	@echo "3. Push: git push gitea main"
	@echo ""

gitea-list-repos: # List repositories in Gitea
	@echo "\n\n***************************** Gitea Repositories \n"
	@echo "Gitea URL: $$(oc get routes -n gitea -o jsonpath='{.items[0].spec.host}' 2>/dev/null || echo 'Not deployed')"
	@echo ""
	@echo "To list repositories, access Gitea UI or:"
	@echo "$$ oc exec -it deployment/gitea -n gitea -- gitea admin user list"
	@echo ""

gitea-delete-repo: # Delete repository from Gitea (requires REPO_NAME)
	@if [ -z "$(REPO_NAME)" ]; then \
		echo "Error: REPO_NAME is required"; \
		echo "Usage: make gitea-delete-repo REPO_NAME=my-repo"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Deleting Gitea Repository: $(REPO_NAME) \n"
	@echo "⚠️  This will delete repository: $(REPO_NAME)"
	@echo "Implementation requires Gitea API integration"
	@echo ""

release: # Push release to GitHub (requires VERSION)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required"; \
		echo "Usage: make release VERSION=v1.0.0"; \
		exit 1; \
	fi
	@echo "\n\n***************************** Pushing Release: $(VERSION) \n"
	@echo "Release version: $(VERSION)"
	@echo ""
	@echo "Steps:"
	@echo "1. Tag release: git tag $(VERSION)"
	@echo "2. Push to GitHub: git push origin $(VERSION)"
	@echo "3. Create release on GitHub UI"
	@echo ""
