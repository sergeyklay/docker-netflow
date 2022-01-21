SHELL ?= /usr/bin/env bash

# PLATFORMS ?= linux/arm64
PLATFORMS ?= linux/arm64,linux/amd64,linux/386,linux/arm/v7,linux/arm/v6

PROJECT_NAME ?= netflow
VERSION ?= 1.0.0

IMAGE_VND  ?= klay
IMAGE_NAME ?= $(IMAGE_VND)/$(PROJECT_NAME)
IMAGE_TAG  ?= $(VERSION)
FQIN       ?= $(IMAGE_NAME):$(IMAGE_TAG)

ifneq ($(TERM),)
	BLUE   := $(shell tput setaf 4)
	RESET  := $(shell tput sgr0)
	M      := $(shell printf "$(BLUE)▶$(RESET) ")
else
	M      := $(shell printf "▶ ")
endif

ifneq "$(wildcard $(CURDIR)/VERSION)" ""
VERSION ?= $(shell cat $(CURDIR)/VERSION | head -n 1)
else
VERSION ?= 1.0.0
endif

BUILD_ID ?= $(shell git rev-parse --short HEAD || echo -n 0000000)

# build project by default
.DEFAULT_GOAL = build

# programs
DOCKER  ?= docker

.PHONY: build
build: Dockerfile
build: ; $(info $(M)build docker image...) @ ## Build docker image
	$(DOCKER) buildx build \
	  --build-arg VERSION="$(VERSION)" \
	  --build-arg BUILD_ID="$(BUILD_ID)" \
	  --platform "$(PLATFORMS)" \
	  --pull \
	  --push \
	  --tag "$(FQIN)" \
	  --tag "$(IMAGE_NAME):latest" .
	@echo

.PHONY: help
help: ## Show this help and exit
	@echo 'Dockerized Netflow Collector v$(VERSION)'
	@echo
	@echo 'Usage:'
	@echo
	@echo '  make TARGET [[ENV_VARIABLE=ENV_VALUE] ...]'
	@echo
	@echo 'Available targets:'
	@echo ''
	@grep -hE '^[a-zA-Z. 0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		 awk 'BEGIN {FS = ":.*?## " }; {printf "  %-13s %s\n", $$1, $$2}'
	@echo
	@echo 'Flags:'
	@echo ''
	@echo '  PLATFORMS:    $(PLATFORMS)'
	@echo
	@echo 'Environment variables:'
	@echo
	@echo '  SHELL:        $(shell echo $$SHELL)'
	@echo '  TERM:         $(shell echo $$TERM)'
	@echo
	@echo 'Docker:'
	@echo
	@echo '  Docker bin:   $(DOCKER)'
	@echo '  Docker image: $(IMAGE_NAME)'
	@echo '  Docker tag:   $(IMAGE_TAG)'
