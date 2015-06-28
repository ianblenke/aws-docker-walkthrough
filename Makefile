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
	@which jq > /dev/null 2>&1 || ( which brew && brew install jq || which apt-get && apt-get install jq || which yum && yum install jq || which choco && choco install jq)
	@aws cloudformation describe-stacks --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION) | jq -r '.Stacks[].Outputs'

outputs:
	@make output | jq -r 'map({key: .OutputKey, value: .OutputValue}) | from_entries'

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

environment:
	eb create $(STACK) --verbose \
	  --profile aws-dev \
	  --tier WebServer \
	  --cname $(shell whoami)-$(STACK) \
	  -p '64bit Amazon Linux 2015.03 v1.4.3 running Docker 1.6.2' \
	  -k $(STACK) \
	  -ip $(shell make outputs | jq -r .InstanceProfile) \
	  --tags Project=$(PROJECT),Environment=$(ENVIRONMENT) \
	  --envvars DEBUG=info \
	  --vpc.ec2subnets=$(shell make outputs | jq -r '[ .VPCSubnet0, .VPCSubnet1, .VPCSubnet2 ] | @csv') \
	  --vpc.elbsubnets=$(shell make outputs | jq -r '[ .VPCSubnet0, .VPCSubnet1, .VPCSubnet2 ] | @csv') \
	  --vpc.publicip --vpc.elbpublic \
	  --vpc.securitygroups=$(shell make outputs | jq -r .VPCSecurityGroup)

