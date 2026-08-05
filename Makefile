.DEFAULT_GOAL := help

CURRENT_DIR := $(shell pwd)

CHART_BASE_VERSION := $(shell grep '^version:' Chart.yaml | awk '{print $$2}')
GIT_TAG ?=
COMMIT_SHORT_SHA ?=

EE_APPVERSION := 7.8.0
EE_DOCKER_REPO := repo.keyfactor.com/images/signserver-ee
DEV_OCI_STORAGE_DSS := oci://keyfactor.jfrog.io/dev-oci/signserver/signserver/charts

.PHONY: help
help:
	@echo "----------------------------------------------------------------------"
	@echo "SignServer Helm Chart Makefile"
	@echo "----------------------------------------------------------------------"
	@echo "This makefile is used to package and publish the SignServer Helm Chart."
	@echo "It supports both Community Edition (CE) and Enterprise Edition (EE)."
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Examples:"
	@echo "  make package-helm-ce   # Package the CE Helm chart"
	@echo "  make publish-helm-ce   # Publish the CE Helm chart to the registry"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s  %s\n", $$1, $$2}'
	@echo ""

.PHONY: package-helm-ce
package-helm-ce: ## Package the CE Helm chart.
	rm -f signserver-*.tgz
	helm package --version $(CHART_BASE_VERSION) $(CURRENT_DIR)

.PHONY: package-helm-ee
package-helm-ee: ## Package the EE Helm chart.
	rm -f signserver-*.tgz
	sed -i 's/^name: .*/name: signserver/' $(CURRENT_DIR)/Chart.yaml
	sed -i '/^annotations:/,/^[^ ]/ { /^[^ ]/!d; /^annotations:/d }' $(CURRENT_DIR)/Chart.yaml
	sed -i 's|repository: keyfactor/signserver-ce|repository: $(EE_DOCKER_REPO)|' $(CURRENT_DIR)/values.yaml
	FINAL_CHART_VERSION="$(CHART_BASE_VERSION)"; \
	CLEAN_TAG=$$(echo "$(GIT_TAG)" | tr -d '[:space:]'); \
	CLEAN_COMMIT_SHORT_SHA=$$(echo "$(COMMIT_SHORT_SHA)" | tr -d '[:space:]'); \
	echo "GIT_TAG=$$CLEAN_TAG and COMMIT_SHORT_SHA=$$CLEAN_COMMIT_SHORT_SHA"; \
	if [ -z "$$CLEAN_TAG" ] && [ -z "$$CLEAN_COMMIT_SHORT_SHA" ]; then \
		echo "Error: GIT_TAG and COMMIT_SHORT_SHA are missing. Please provide one of them."; \
		exit 1; \
	elif [ -z "$$CLEAN_TAG" ] && [ -n "$$CLEAN_COMMIT_SHORT_SHA" ]; then \
		FINAL_CHART_VERSION="$(CHART_BASE_VERSION)-$(COMMIT_SHORT_SHA)"; \
	elif [ -n "$$CLEAN_TAG" ] && [ "$$CLEAN_TAG" != "$(CHART_BASE_VERSION)" ]; then \
    	echo "Error: GIT_TAG does not match the version in Chart.yaml"; \
		exit 1; \
	fi; \
	echo "Final Chart version: $$FINAL_CHART_VERSION"; \
	helm package --version $$FINAL_CHART_VERSION --app-version $(EE_APPVERSION) $(CURRENT_DIR);

.PHONY: publish-helm-ce
publish-helm-ce: ## Publish the CE Helm chart to the OCI registry.
	ce_pkg=$$(ls signserver-ce-*.tgz); \
	if [ -z "$$ce_pkg" ]; then \
		echo "Error: No CE package found. Run 'make package-helm-ce' first."; \
		exit 1; \
	fi; \
	echo "Publishing $$ce_pkg..."; \
	helm push $$ce_pkg $(DEV_OCI_STORAGE_DSS)

.PHONY: publish-helm-ee
publish-helm-ee: ## Publish the EE Helm chart to the OCI registry.
	ee_pkg=$$(ls signserver-*.tgz); \
	if [ -z "$$ee_pkg" ]; then \
		echo "Error: No EE package found. Run 'make package-helm-ee' first."; \
		exit 1; \
	fi; \
	echo "Publishing $$ee_pkg..."; \
	helm push $$ee_pkg $(DEV_OCI_STORAGE_DSS)
