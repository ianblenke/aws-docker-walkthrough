PROJECT:=myapp
ENVIRONMENT:=dev
STACK:=$(PROJECT)-$(ENVIRONMENT)
DESCRIPTION:=My Application
TEMPLATE:=cloudformation-template_vpc-iam.json
PARAMETERS:=cloudformation-parameters_myapp-dev.json
AWS_REGION:=us-east-1
AWS_PROFILE:=aws-dev

all:
	@which aws || pip install awscli
	aws cloudformation create-stack --stack-name $(STACK) --template-body file://`pwd`/$(TEMPLATE) --parameters file://`pwd`/$(PARAMETERS) --capabilities CAPABILITY_IAM --profile $(AWS_PROFILE) --region $(AWS_REGION)

update:
	aws cloudformation update-stack --stack-name $(STACK) --template-body file://`pwd`/$(TEMPLATE) --parameters file://`pwd`/$(PARAMETERS) --capabilities CAPABILITY_IAM --profile $(AWS_PROFILE) --region $(AWS_REGION)

events:
	aws cloudformation describe-stack-events --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)

watch:
	watch --interval 10 "bash -c 'make events | head -25'"

output:
	@which jq || ( which brew && brew install jq || which apt-get && apt-get install jq || which yum && yum install jq || which choco && choco install jq)
	aws cloudformation describe-stacks --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION) | jq -r '.Stacks[].Outputs'

delete:
	aws cloudformation delete-stack --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)


application:
	aws elasticbeanstalk create-application \
	  --profile aws-dev \
	  --region us-east-1 \
	  --application-name $(PROJECT) \
	  --description "$(DESCRIPTION)"

~/.ssh/$(STACK):
	ssh-keygen -t rsa -b 2048 -f ~/.ssh/$(STACK) -P ''
	aws ec2 import-key-pair --key-name $(STACK) --public-key-material "$$(cat ~/.ssh/$(STACK).pub)"

