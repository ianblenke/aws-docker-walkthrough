STACK:=myapp-dev
TEMPLATE:=cloudformation-template_vpc-iam.json
PARAMETERS:=cloudformation-parameters_myapp-dev.json
AWS_REGION:=us-east-1
AWS_PROFILE:=aws-dev

all:
	which aws || pip install awscli
	aws cloudformation create-stack --stack-name $(STACK) --template-body file://`pwd`/$(TEMPLATE) --parameters file://`pwd`/$(PARAMETERS) --capabilities CAPABILITY_IAM --profile $(AWS_PROFILE) --region $(AWS_REGION)

update:
	aws cloudformation update-stack --stack-name $(STACK) --template-body file://`pwd`/$(TEMPLATE) --parameters file://`pwd`/$(PARAMETERS) --capabilities CAPABILITY_IAM --profile $(AWS_PROFILE) --region $(AWS_REGION)

events:
	aws cloudformation describe-stack-events --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)

watch:
	watch --interval 10 "bash -c 'make events | head -25'"

delete:
	aws cloudformation delete-stack --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)

