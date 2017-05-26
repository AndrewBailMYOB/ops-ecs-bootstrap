.DEFAULT_GOAL := help
SHELL         := /bin/bash

KEYNAME  := ops-ecs-key
STACKNET := ops-ecs-network
STACKECS := ops-ecs-cluster
P_REGION := ap-southeast-2
T_REGION := us-west-2

.PHONY: help stack delete test delete-test

stack:
	@export AWS_DEFAULT_REGION=$(P_REGION); \
	./scripts/create_keypair.sh $(KEYNAME) && \
	./scripts/deploy_stack.sh $(STACKNET) network/template.yml network/params.json && \
	./scripts/deploy_stack.sh $(STACKECS) ecs-cluster/template.yml ecs-cluster/params.json && \
	echo ":cloudformation: :trophy:"

delete:
	#aws cloudformation delete-stack \
	#	--stack-name $(STACK_NAME)
	#@echo "Waiting for stack deletion to complete ..."
	#aws cloudformation wait stack-delete-complete --stack-name $(STACK_NAME)
	@echo 'not implemented :('

test: test-scripts
	@echo "--- :checkered_flag: Building test stack"
	export AWS_DEFAULT_REGION=$(T_REGION); \
	echo "--- :key: Creating keypair"; \
	./scripts/create_keypair.sh $(KEYNAME) && \
	echo "--- :cloudformation: Building network stack" &&  \
	./scripts/deploy_stack.sh $(STACKNET) network/template.yml network/params_test.json && \
	echo "--- :cloudformation: Building ECS cluster stack" &&  \
	./scripts/deploy_stack.sh $(STACKECS) ecs-cluster/template.yml ecs-cluster/params_test.json && \
	echo "--- :trophy: Test stack built!"

delete-test:
	@echo "--- :gun: Deleting test stack"; \
	export AWS_DEFAULT_REGION=$(T_REGION); \
	echo "--- :key: Deleting keypair"; \
	aws ec2 delete-key-pair --key-name $(KEYNAME) && \
	rm -f $(KEYNAME).pem && \
	echo "--- :cloudformation: Deleting ECS cluster stack" && \
	aws cloudformation delete-stack --stack-name $(STACKECS) && \
	aws cloudformation wait stack-delete-complete --stack-name $(STACKECS) && \
	echo "--- :cloudformation: Deleting network stack" && \
	aws cloudformation delete-stack --stack-name $(STACKNET) && \
	aws cloudformation wait stack-delete-complete --stack-name $(STACKNET) && \
	echo "--- :trophy: Test stack deleted!"

test-scripts:
	@echo '--- :bash: Testing scripts'
	docker run -v "$(PWD):/mnt" koalaman/shellcheck scripts/*.sh

help:
	@echo ''
	@echo '-------------------------------------------------------'
	@echo "Orlando's Amazing Stack Buildy Thing!"
	@echo '-------------------------------------------------------'
	@echo ''
	@echo 'To execute against ap-southeast-2: make stack'
	@echo ''
	@echo 'The templates that will be submitted for execution are:'
	@echo 'network/template.yml'
	@echo 'ecs-cluster/template.yml'
	@echo ''
	@echo 'In that order; there are output dependencies.'
	@echo 'You can find the parameters in those directories.'
	@echo ''
	@echo 'To test the stack, execute: make test'
	@echo 'This will build out a test stack in $(T_REGION).'
	@echo 'To tear-down the test stack: make delete-test'
	@echo ''
	@echo 'Enjoy this fine aguardiente con moderación.'
	@echo '-------------------------------------------------------'
	@echo ''
