STACK_NAME    ?= example
DEFAULT_REGION ?= ap-southeast-2
REGION        := ${DEFAULT_REGION}
STACK_TEMPLATE_FILE := "$(CFN_LOCATION)"
STACK_PARAMS_FILE   := "$(CFN_PARAMS)"

export AWS_DEFAULT_REGION := $(REGION)

.PHONY: buildStack deleteStack help

help:
	@echo "make buildStack STACK_NAME=<stackName> CFN_LOCATION=<Cloudformation template location> CFN_PARAMETERS=<Parameters json file location> DEFAULTREGION=aws_region (optional if region=ap-souteast-2"

buildStack:
	./scripts/deploy_stack.sh $(STACK_NAME) $(STACK_TEMPLATE_FILE) $(STACK_PARAMS_FILE)

deleteStack:
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME)
	@echo "Waiting for stack deletion to complete ..."
	aws cloudformation wait stack-delete-complete --stack-name $(STACK_NAME)
