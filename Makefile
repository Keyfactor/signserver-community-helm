.DEFAULT_GOAL := help

CURRENT_DIR := $(shell pwd)

CHART_BASE_VERSION := $(shell grep '^version:' Chart.yaml | awk '{print $$2}')
GIT_TAG ?=
COMMIT_SHORT_SHA ?=

EE_APPVERSION := 7.8.0
EE_DOCKER_REPO := repo.keyfactor.com/images/signserver-ee
DEV_OCI_STORAGE_DSS := oci://keyfactor.jfrog.io/dev-oci-storage-dss/signserver/signserver/charts/

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
	sed -i 's/^name: .*/name: signserver/' Chart.yaml
	sed -i '/^annotations:/,$$d' $(CURRENT_DIR)/Chart.yaml
	sed -i 's|repository: keyfactor/signserver-ce|repository: $(EE_DOCKER_REPO)|' $(CURRENT_DIR)/values.yaml
	FINAL_CHART_VERSION="$(CHART_BASE_VERSION)"; \
	echo "GIT_TAG= $(GIT_TAG) and COMMIT_SHORT_SHA= $(COMMIT_SHORT_SHA)"; \
	CLEAN_TAG=$$(echo "$(GIT_TAG)" | tr -d '[:space:]'); \
	echo "CLEAN_TAG=$$CLEAN_TAG"; \
	if [ -z "$$CLEAN_TAG" ]; then \
		echo "Zero length tag"; \
	elif [ "$$CLEAN_TAG" != "$(CHART_BASE_VERSION)" ]; then \
  		echo "ERROR: Git tag does not match the version in Chart.yaml"; \
  		echo "Chart base version: $(CHART_BASE_VERSION), GIT_TAG= $(GIT_TAG)"; \
  		exit 1; \
	fi;
	if [ -z "$$CLEAN_TAG" ] && [ -z "$(COMMIT_SHORT_SHA)" ]; then \
		echo "ERROR: COMMIT_SHORT_SHA is missing"; \
		echo "COMMIT_SHORT_SHA= $(COMMIT_SHORT_SHA)"; \
		exit 1; \
	elif [ -z "$(GIT_TAG)" ] && [ -n "$(COMMIT_SHORT_SHA)" ]; then \
		FINAL_CHART_VERSION="$(CHART_BASE_VERSION)-$(COMMIT_SHORT_SHA)"; \
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
