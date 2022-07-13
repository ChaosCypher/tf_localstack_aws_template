########################
# Localstack Variables #
########################

# aws services that will be created in the localstack container
AWS_SERVICES := cloudtrail,cloudwatch,dynamodb,iam,logs,s3

# the default region to be used in localstack
REGION := us-west-2

# the s3 bucket name where terraform state will be stored
TF_BUCKET_NAME := tf-state-bucket

# the dynamodb table that will handle terraform state locking
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

# the name of the dockerfile
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

# the backend state configuration file for development
DEV_BACKEND_CONFIG := $(abspath tfvars/development-backend)

# the terraform variable file for development
DEV_VARS_FILE := $(abspath tfvars/development.tfvars)

##################
# Docker Targets #
##################

# build the localstack container
.PHONY: build-container
build-container: internal-check-docker-file
	@docker build \
	  -t $(DOCKER_IMAGE) \
	  -f $(DOCKER_FILE) .

# stop the localstack container
.PHONY: stop-container
stop-container:
	@docker ps -a --filter=status=running | awk '$$1 != "CONTAINER" {print $$1}' | xargs -I {} docker stop {}

# remove all created localstack images
.PHONY: clean-docker
clean-docker:
	@docker ps -a --filter=status=exited | awk '$$1 != "CONTAINER" {print $$1}' | xargs -I {} docker rm {}
	@docker images | awk '$$1 == "<none>" || $$1 ~ /^$(DOCKER_IMAGE).*$$/ {print $$3}' | xargs -I {} docker rmi -f {}

# check that the dockerfile exists in the project
.PHONY: internal-check-docker-file
internal-check-docker-file:
ifeq ($(DOCKER_FILE),)
	@echo "ERROR: No Dockerfile with name '$(DOCKER_FILE_NAME)' was found while recursively searching '$(project_dir)'"
	@exit 1
endif

# run the localstack container
.PHONY: run-container
run-container:
	@docker run \
      -e LOCALSTACK_SERVICES="$(AWS_SERVICES)" \
      -p 4566:4566 \
      -p 4510-4559:4510-4559 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "${LOCALSTACK_VOLUME_DIR:-./volume}:/var/lib/localstack" \
	  --rm -d $(DOCKER_IMAGE)

# internal-check calls internal-check-docker-file
.PHONY: internal-check
internal-check: internal-check-docker-file

# wait for the localstack container to have a healthy status
.PHONY: wait-container-healthy
wait-container-healthy:
	@while [ "`docker ps -a --filter=status=running | awk '$$1 != "CONTAINER" {print $$1}' | xargs -I {} docker container inspect -f {{.State.Health.Status}} {}`" != "healthy" ]; do \
      echo "Waiting for container to come up healthy..." && sleep 2; \
  done;

#####################
# Terraform Targets #
#####################

# create the s3 bucket in the localstack container for terraform remote state
.PHONY: tf-create-s3-bucket
tf-create-s3-bucket:
	@AWS_PAGER="" aws --endpoint-url http://localhost:4566 s3api create-bucket --bucket $(TF_BUCKET_NAME) --region $(REGION) --create-bucket-configuration LocationConstraint=$(REGION)

# create the dynamodb table in the localstack container for terraform remote state locking
.PHONY: tf-create-dynamodb
tf-create-dynamodb:
	@AWS_PAGER="" aws --endpoint-url http://localhost:4566 dynamodb create-table --table-name $(TF_DYNAMO_NAME) --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# run a terraform init with the backend using the localstack container
.PHONY: tf-init
tf-init:
	@terraform init -backend-config=$(DEV_BACKEND_CONFIG)

# run a terraform apply against the localstack container using the development tfvars file
.PHONY: tf-apply
tf-plan:
	@terraform apply -var-file=$(DEV_VARS_FILE) -auto-approve

#######################
# Development Targets #
#######################

# creates and deploys localstack development environment, applies terraform resources against it, then tears it all down (intended for CI)
.PHONY: integration-test-ci
integration-test-ci: internal-check deploy-localstack bootstrap-tf-backend deploy-terraform clean

# creates and deploys a localstack development environment, then applies terraform resources against it
.PHONY: local-development
local-development: internal-check deploy-localstack bootstrap-tf-backend deploy-terraform

##################
# Helper Targets #
##################

# builds and runs a localstack container
.PHONY: deploy-localstack
deploy-localstack: build-container run-container

# creates the resources needed for terraform to use a remote s3 backend in localstack
.PHONY: bootstrap-tf-backend
bootstrap-tf-backend: wait-container-healthy tf-create-s3-bucket tf-create-dynamodb

# applies terraform resources against the localstack container
.PHONY: deploy-terraform
deploy-terraform: tf-init tf-plan

# stop all localstack containers and remove the images
.PHONY: clean
clean: stop-container clean-docker
