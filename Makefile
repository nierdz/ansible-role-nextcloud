SHELL := /usr/bin/env bash
MAIN_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
VIRTUALENV_DIR := $(MAIN_DIR)/venv

help: ## Print this help
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

venv: ## Create python virtualenv if not exists
	@[[ -d $(VIRTUALENV_DIR) ]] || python3 -m virtualenv --system-site-packages $(VIRTUALENV_DIR)

install: ## Install pip dependencies
	$(info --> Install pip dependencies)
	@$(MAKE) venv
	@( \
		source $(VIRTUALENV_DIR)/bin/activate; \
		pip3 install --upgrade setuptools; \
		pip3 install -r requirements.txt; \
	)

pre-commit: ## Run pre-commit tests
	$(info --> Run pre-commit tests)
	@( \
		source $(VIRTUALENV_DIR)/bin/activate; \
		pre-commit run --all-files; \
	)
certs:
	mkdir certs

mkcert: certs ## Create certs if needed
	$(info --> Create certs if needed)
	@(if [[ -e $(MAIN_DIR)/certs/nextcloud.local-key.pem ]] && [[ -e $(MAIN_DIR)/certs/nextcloud.local.pem ]]; then \
			openssl verify -CAfile ~/.local/share/mkcert/rootCA.pem $(MAIN_DIR)/certs/nextcloud.local.pem; \
		else \
			mkcert \
				-cert-file $(MAIN_DIR)/certs/nextcloud.local.pem \
				-key-file $(MAIN_DIR)/certs/nextcloud.local-key.pem \
				"nextcloud.local"; \
		fi; \
	)
