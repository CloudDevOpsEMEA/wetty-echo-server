APP_NAME=wetty-demo
DOCKER_ACCOUNT=boeboe
VERSION=1.0.0

WETTY_PORT=3000
TCP_ECHO_PORT=3001
UDP_ECHO_PORT=3002
EXPOSED_WETTY_PORT=8080
EXPOSED_TCP_ECHO_PORT=8081
EXPOSED_UDP_ECHO_PORT=8082
PORT_MAPPING=-p=$(EXPOSED_WETTY_PORT):${WETTY_PORT} -p=$(EXPOSED_TCP_ECHO_PORT):${TCP_ECHO_PORT} -p=$(EXPOSED_UDP_ECHO_PORT):${UDP_ECHO_PORT}/udp

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS

build: ## Build the container
	docker build -t $(DOCKER_ACCOUNT)/$(APP_NAME) .

build-nc: ## Build the container without caching
	docker build --no-cache -t $(DOCKER_ACCOUNT)/$(APP_NAME) .

run: ## Run container
	docker run -i -t --rm ${PORT_MAPPING} --name="$(APP_NAME)" $(DOCKER_ACCOUNT)/$(APP_NAME)

run-sh: ## Run interactive shell in container
	docker run -i -t --entrypoint /bin/sh --name="$(APP_NAME)" $(DOCKER_ACCOUNT)/$(APP_NAME)

login-sh: ## Login with shell in running container
	docker exec -i -t $(APP_NAME) /bin/sh

up: build run ## Build and run container on port configured

stop: ## Stop and remove a running container
	docker stop $(APP_NAME) || true
	docker rm $(APP_NAME) || true

release: build-nc publish ## Make a full release

publish: publish-latest publish-version ## Publish the $VERSION and latest tagged containers

publish-latest: tag-latest
	@echo 'publish latest to $(DOCKER_ACCOUNT)/$(APP_NAME)'
	docker push $(DOCKER_ACCOUNT)/$(APP_NAME):latest

publish-version: tag-version
	@echo 'publish $(VERSION) to $(DOCKER_ACCOUNT)/$(APP_NAME)'
	docker push $(DOCKER_ACCOUNT)/$(APP_NAME):$(VERSION)

tag: tag-latest tag-version

tag-latest:
	@echo 'create tag latest'
	docker tag $(DOCKER_ACCOUNT)/$(APP_NAME) $(DOCKER_ACCOUNT)/$(APP_NAME):latest

tag-version:
	@echo 'create tag $(VERSION)'
	docker tag $(DOCKER_ACCOUNT)/$(APP_NAME) $(DOCKER_ACCOUNT)/$(APP_NAME):$(VERSION)

deploy-k8s: ## Deploy onto kubernetes
	kubectl apply -f ./kubernetes

undeploy-k8s: ## Undeploy from kubernetes
	kubectl delete -f ./kubernetes