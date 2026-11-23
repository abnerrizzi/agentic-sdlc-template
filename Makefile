# All verifier logic lives in scripts/. CI wrappers only install the pinned
# tools and run "make check", so the result is the same locally, in the
# agent's verify loop and in CI.
SHELL := bash
.DEFAULT_GOAL := help

# Tool pins: CHECK_IMAGE, *_VERSION, *_SHA256_*.
include tools.versions

# Optional registry mirror prefix for the check image, with a trailing slash,
# for networks that cannot reach Docker Hub. Set it in your shell, never commit it.
# Example: make check-docker IMAGE_MIRROR=registry.example.internal:5000/
IMAGE_MIRROR ?=

# The local image tag changes whenever an input to the toolchain changes.
CHECK_INPUTS := ci/Dockerfile tools.versions package.json package-lock.json requirements-lint.txt scripts/lib.sh scripts/install-tools.sh scripts/doctor.sh
CHECK_TAG := agentic-sdlc-check:$(shell cat $(CHECK_INPUTS) 2>/dev/null | sha256sum | cut -c1-12)

.PHONY: help check doctor install-tools check-docker \
	check-secrets check-text check-markdown check-links check-yaml check-shell \
	check-template-sync verifier-guard

help: ## List targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{ printf "  %-20s %s\n", $$1, $$2 }'

check: ## Run every verifier; fails on any error
	@scripts/run-checks.sh

doctor: ## List required tools, versions and install hints (installs nothing)
	@scripts/doctor.sh

install-tools: ## Download the pinned tools into TOOLS_DIR (network; checks sha256)
	@scripts/install-tools.sh

# Runs make check in the pinned container: no network at check time, repo
# mounted read-only, your UID, so it cannot change your files.
check-docker: ## Run make check inside the pinned container
	docker build --file ci/Dockerfile --tag $(CHECK_TAG) \
	  --build-arg CHECK_IMAGE=$(IMAGE_MIRROR)$(CHECK_IMAGE) \
	  --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy \
	  --build-arg HTTP_PROXY --build-arg HTTPS_PROXY --build-arg NO_PROXY \
	  .
	docker run --rm --network none \
	  --user "$$(id -u):$$(id -g)" \
	  --env HOME=/tmp --env NO_COLOR --env GUARD_BASE \
	  --env GIT_CONFIG_COUNT=1 --env GIT_CONFIG_KEY_0=safe.directory --env GIT_CONFIG_VALUE_0='*' \
	  --volume "$(CURDIR):/repo:ro" --workdir /repo \
	  $(CHECK_TAG) scripts/run-checks.sh

check-secrets: ## gitleaks over history, changes and new files
	@scripts/check-secrets.sh
check-text: ## No em dashes, no wikilinks
	@scripts/check-text.sh
check-markdown: ## markdownlint-cli2
	@scripts/check-markdown.sh
check-links: ## lychee, offline, internal links and anchors
	@scripts/check-links.sh
check-yaml: ## yamllint, strict
	@scripts/check-yaml.sh
check-shell: ## shellcheck
	@scripts/check-shell.sh
check-template-sync: ## GitHub and GitLab templates have the same content
	@scripts/check-template-sync.sh
verifier-guard: ## Verifier and non-verifier paths never change together
	@scripts/verifier-guard.sh
