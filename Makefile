INGRESS_DOMAIN ?= example.com

.PHONY: bazel-target-list
bazel-target-list: ## List bazel targets
	bazel query '...'

.PHONY: build-image
build-image: ## Build docker image
	bazel run //:bundle --verbose_failures

.PHONY: push-image
push-image: ## Push docker image
	bazel run //:push --verbose_failures

.PHONY: check-yaml
check-yaml: ## Check k8s yaml
	bazel run //:k8s --define ingress_domain=$(INGRESS_DOMAIN) --verbose_failures

.PHONY: apply-yaml
apply-yaml: ## Apply k8s yaml
	bazel run //:k8s.apply --define ingress_domain=$(INGRESS_DOMAIN) --verbose_failures

.PHONY: print-workspace-status
print-workspace-status: ## Print workspace status
	hack/print-workspace-status.sh

.PHONY: help
help: ## List commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-50s\033[0m %s\n", $$1, $$2}'
