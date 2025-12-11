.DEFAULT_GOAL := help

CURRENT_DIR := $(shell pwd)

EE_APPVERSION := 7.4.0
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

# Reusable script to rename the chart file
# 1. Finds the chart file (signserver-*.tgz)
# 2. Constructs the new name with the suffix (e.g., -ce or -ee)
# 3. Renames the file
define RENAME_CHART_SCRIPT
	orig=$$(ls signserver-*.tgz); \
	new_name=$$(echo $$orig | sed -E 's/(.+)-([0-9].*)\.tgz/\1-$(1)-\2.tgz/'); \
	echo "Renaming $$orig $$new_name"; \
	mv $$orig $$new_name
endef

.PHONY: package-helm-ce
package-helm-ce: ## Package the CE Helm chart.
	rm -f signserver-*.tgz
	helm package $(CURRENT_DIR)
	$(call RENAME_CHART_SCRIPT,ce)

.PHONY: package-helm-ee
package-helm-ee: ## Package the EE Helm chart.
	rm -f signserver-*.tgz
	sed -i '/^annotations:/,$$d' $(CURRENT_DIR)/Chart.yaml
	sed -i 's|repository: keyfactor/signserver-ce|repository: $(EE_DOCKER_REPO)|' $(CURRENT_DIR)/values.yaml
	helm package --app-version $(EE_APPVERSION) $(CURRENT_DIR)

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
	ee_pkg=$$(ls signserver-ee-*.tgz); \
	if [ -z "$$ee_pkg" ]; then \
		echo "Error: No EE package found. Run 'make package-helm-ee' first."; \
		exit 1; \
	fi; \
	echo "Publishing $$ee_pkg..."; \
	helm push $$ee_pkg $(DEV_OCI_STORAGE_DSS)
