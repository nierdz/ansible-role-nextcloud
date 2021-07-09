SHELL := /usr/bin/env bash
MAIN_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
VIRTUALENV_DIR := $(MAIN_DIR)/venv
PATH := $(VIRTUALENV_DIR)/bin:$(PATH)

export PATH

help: ## Print this help
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

$(VIRTUALENV_DIR):
	virtualenv -p $(shell command -v python3) $(VIRTUALENV_DIR)

$(VIRTUALENV_DIR)/bin/ansible: $(MAIN_DIR)/requirements.txt
	pip install -r $(MAIN_DIR)/requirements.txt
	@touch '$(@)'

install: $(VIRTUALENV_DIR) $(VIRTUALENV_DIR)/bin/ansible ## Install python pip packages in a virtual environment

pre-commit: ## Run pre-commit tests
	pre-commit run --all-files

certs:
	mkdir certs

mkcert: certs ## Create certs if needed
	if [[ -e $(MAIN_DIR)/certs/nextcloud.local-key.pem ]] && [[ -e $(MAIN_DIR)/certs/nextcloud.local.pem ]]; then \
		openssl verify -CAfile ~/.local/share/mkcert/rootCA.pem $(MAIN_DIR)/certs/nextcloud.local.pem; \
	else \
		mkcert \
			-cert-file $(MAIN_DIR)/certs/nextcloud.local.pem \
			-key-file $(MAIN_DIR)/certs/nextcloud.local-key.pem \
			"nextcloud.local"; \
	fi
