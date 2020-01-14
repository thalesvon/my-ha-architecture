#!/bin/bash

PROJECT='my-ha-architecture'

aws s3 ls s3://${PROJECT} &> /dev/null
if [ $? -ne 0 ];then
    echo 'Bucket does not exist, creating one...'
    aws s3 mb s3://${PROJECT}
fi

aws s3 sync ./templates s3://${PROJECT} --exclude helper.sh --exclude ".git/*" --exclude "README.md"

aws cloudformation describe-stacks --stack-name ${PROJECT} &> /dev/null
if [ $? -ne 0 ];then
    echo 'Stack does not exist, create will be executed...'
    aws cloudformation create-stack --stack-name ${PROJECT} \
                                    --capabilities CAPABILITY_IAM \
                                    --template-body file://templates/main.yml \
                                    --parameters ParameterKey=TemplatesBucket,ParameterValue=${PROJECT} ParameterKey=ProjectName,ParameterValue=${PROJECT}
else
    echo 'Stack exists, update will be executed...'
    aws cloudformation update-stack --stack-name ${PROJECT} \
                                    --capabilities CAPABILITY_IAM \
                                    --template-body file://templates/main.yml \
                                    --parameters ParameterKey=TemplatesBucket,ParameterValue=${PROJECT} ParameterKey=ProjectName,ParameterValue=${PROJECT}
                                    
fi