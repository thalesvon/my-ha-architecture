#!/bin/bash

PROJECT="my-ha-architecture"
DNS_STACK="dns-permanent"

PROJECT_TEMPLATE="templates/main.yml"
DNS_TEMPLATE="templates/dns.yml"

aws s3 ls s3://${PROJECT} &> /dev/null
if [ $? -ne 0 ];then
    echo "Bucket does not exist, creating one..."
    aws s3 mb s3://${PROJECT}
fi

aws s3 sync ./templates s3://${PROJECT} --exclude helper.sh --exclude ".git/*" --exclude "README.md"

aws cloudformation describe-stacks --stack-name ${PROJECT} &> /dev/null
if [ $? -ne 0 ];then
    echo "Stack ${PROJECT} does not exist, create will be executed..."
    aws cloudformation create-stack --stack-name ${PROJECT} \
                                    --capabilities CAPABILITY_NAMED_IAM \
                                    --template-body file://${PROJECT_TEMPLATE} \
                                    --parameters ParameterKey=TemplatesBucket,ParameterValue=${PROJECT} ParameterKey=ProjectName,ParameterValue=${PROJECT}
else
    echo "Stack ${PROJECT} exists, update will be executed..."
    aws cloudformation update-stack --stack-name ${PROJECT} \
                                    --capabilities CAPABILITY_NAMED_IAM \
                                    --template-body file://${PROJECT_TEMPLATE} \
                                    --parameters ParameterKey=TemplatesBucket,ParameterValue=${PROJECT} ParameterKey=ProjectName,ParameterValue=${PROJECT}  
fi

aws cloudformation describe-stacks --stack-name ${DNS_STACK} &> /dev/null
if [ $? -ne 0 ];then
    echo "Stack ${DNS_STACK} does not exist, create will be executed..."
    aws cloudformation create-stack --stack-name ${DNS_STACK} \
                                    --capabilities CAPABILITY_NAMED_IAM \
                                    --template-body file://${DNS_TEMPLATE} \
                                    --enable-termination-protection
else
    echo "Stack ${DNS_STACK} exists, no action will be executed..."
    #aws cloudformation update-stack --stack-name ${DNS_STACK} \
    #                                --capabilities CAPABILITY_NAMED_IAM \
    #                                --template-body file://${DNS_TEMPLATE}                                   
fi