.DEFAULT_GOAL = help

.PHONY: help
help:
	@awk -F": |##" '/^[^\.][0-9a-zA-Z\._\-\%]+:+.+##.+$$/ { printf "\033[36m%-26s\033[0m %s\n", $$1, $$3 }' $(MAKEFILE_LIST) \
	| sort

.PHONY: tests
tests: ## Run unit tests
	docker build --target tests .

.PHONY: docker-push
docker-push: ## Run unit tests, build and push docker image
	docker build -t ansd/lastpass .
	docker push ansd/lastpass
