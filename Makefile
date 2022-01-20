PLATFORMS ?= linux/amd64,linux/arm64
VERSION ?= 1.0.0

IMAGE_VND  ?= klay
IMAGE_NAME ?= $(IMAGE_VND)/netflow
IMAGE_TAG  ?= $(VERSION)
FQIN       ?= $(IMAGE_NAME):$(IMAGE_TAG)

# build project by default
.DEFAULT_GOAL = build

# programs
DOCKER  ?= docker

.PHONY: build
build: Dockerfile
build: ; $(info $(M)build docker image...) @ ## Build docker image
	$(DOCKER) buildx build \
	  --platform "$(PLATFORMS)" \
	  --pull \
	  --push \
	  --tag "$(FQIN)" .
	@echo
	@echo "$(M)To run docker image use: $(DOCKER) run --tty --interactive --publish 80:80 --rm $(IMAGE_NAME):$(IMAGE_TAG)"
