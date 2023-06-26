export DOCKER_IMAGE_NAME=verdecooperation/arbitbox

build-push-test-m1: ## Builds test docker image on M1 Mac
	docker buildx build --platform linux/amd64 . --file Dockerfile --tag "$(DOCKER_IMAGE_NAME)" --push