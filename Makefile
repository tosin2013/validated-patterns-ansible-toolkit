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
