########################
# Localstack Variables #
########################
AWS_SERVICES := cloudtrail,cloudwatch,dynamodb,iam,logs,s3
REGION := us-west-2
TF_BUCKET_NAME := tf-state-bucket
TF_DYNAMO_NAME := terraform-backend-lock

##################
# Path Variables #
##################

# locate the top-level directory of the project
project_dir := $(shell cd $(dir $(lastword $(MAKEFILE_LIST)))/.. && pwd)

# the current working directory where make was invoked from
CWD := $(shell basename $$PWD)

####################
# Docker Variables #
####################

# The name of the dockerfile
DOCKER_FILE_NAME ?= Dockerfile.test

# determine the location of the Dockerfile
DOCKER_FILE ?= $(shell while [[ "$$(pwd)" != "$(abspath $(project_dir)/..)" ]]; do \
		         test -f "$(DOCKER_FILE_NAME)" && echo "$$(pwd)/$(DOCKER_FILE_NAME)" && break; \
		         pushd $$(pwd)/.. >> /dev/null; \
		       done)

# set the docker image name
DOCKER_IMAGE ?= $(shell echo $(CWD) | tr A-Z a-z | tr -cd '[:alnum:]' )

#######################
# Terraform Variables #
#######################

DEV_BACKEND_CONFIG := $(abspath tfvars/development-backend)
DEV_VARS_FILE := $(abspath tfvars/development.tfvars)

##################
# Docker Targets #
##################

.PHONY: build-container
build-container: internal-check-docker-file
	@docker build \
	  -t $(DOCKER_IMAGE) \
	  -f $(DOCKER_FILE) .

.PHONY: stop-container
stop-container:
	@docker ps -a --filter=status=running | awk '$$1 != "CONTAINER" {print $$1}' | xargs -I {} docker stop {}

.PHONY: clean-docker
clean-docker:
	@docker ps -a --filter=status=exited | awk '$$1 != "CONTAINER" {print $$1}' | xargs -I {} docker rm {}
	@docker images | awk '$$1 == "<none>" || $$1 ~ /^$(DOCKER_IMAGE).*$$/ {print $$3}' | xargs -I {} docker rmi -f {}

.PHONY: internal-check-docker-file
internal-check-docker-file:
ifeq ($(DOCKER_FILE),)
	@echo "ERROR: No Dockerfile with name '$(DOCKER_FILE_NAME)' was found while recursively searching '$(project_dir)'"
	@exit 1
endif

.PHONY: run-container
run-container:
	@docker run \
    -e LOCALSTACK_SERVICES="$(AWS_SERVICES)" \
    -p 4566:4566 \
    -p 4510-4559:4510-4559 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "${LOCALSTACK_VOLUME_DIR:-./volume}:/var/lib/localstack" \
	  --rm -d $(DOCKER_IMAGE)

.PHONY: internal-check
internal-check: internal-check-docker-file

.PHONY: wait-container-healthy
wait-container-healthy:
	@while [ "`docker ps -a --filter=status=running | awk '$$1 != "CONTAINER" {print $$1}' | xargs -I {} docker container inspect -f {{.State.Health.Status}} {}`" != "healthy" ]; do \
      echo "Waiting for container to come up healthy..." && sleep 2; \
  done;

#####################
# Terraform Targets #
#####################

.PHONY: tf-create-s3-bucket
tf-create-s3-bucket:
	@aws --endpoint-url http://localhost:4566 s3api create-bucket --bucket $(TF_BUCKET_NAME) --region $(REGION) --create-bucket-configuration LocationConstraint=$(REGION)

.PHONY: tf-create-dynamodb
tf-create-dynamodb:
	@aws --endpoint-url http://localhost:4566 dynamodb create-table --table-name $(TF_DYNAMO_NAME) --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

.PHONY: tf-init
tf-init:
	@terraform init -backend-config=$(DEV_BACKEND_CONFIG)

.PHONY: tf-plan
tf-plan:
	@terraform apply -var-file=$(DEV_VARS_FILE) -auto-approve

#######################
# Development Targets #
#######################

.PHONY: test
test: internal-check build-container run-container wait-container-healthy tf-create-s3-bucket tf-create-dynamodb tf-init tf-plan stop-container
