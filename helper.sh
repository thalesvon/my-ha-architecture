#!/bin/bash

PROJECT="my-ha-architecture"
DNS_STACK="dns-permanent"

PROJECT_TEMPLATE="templates/main.yml"
DNS_TEMPLATE="templates/dns.yml"
RAND="1f22e2fe68aa"
BASTION_KEY="BastionKey"
ECS_KEY="EcsInstancesKey"

SSL_CERT=$(aws acm request-certificate --domain-name "${RAND}.com" --validation-method DNS --idempotency-token "${RAND}" --output text)

aws s3 ls s3://${PROJECT}-${RAND} &> /dev/null
if [ $? -ne 0 ];then
    echo "Bucket does not exist, creating one..."
    #Bucket must be unique globally
   
    aws s3 mb s3://${PROJECT}-${RAND}
    echo "Bucket ${PROJECT}-${RAND} created"
fi

aws s3 cp ./templates s3://"${PROJECT}-${RAND}" --recursive --exclude helper.sh --exclude ".git/*" --exclude "README.md"

aws cloudformation describe-stacks --stack-name ${PROJECT} &> /dev/null
if [ $? -ne 0 ];then
    echo "Stack ${PROJECT} does not exist, create will be executed..."
    aws cloudformation create-stack --stack-name ${PROJECT} \
                                    --capabilities CAPABILITY_NAMED_IAM \
                                    --template-body file://${PROJECT_TEMPLATE} \
                                    --parameters ParameterKey=TemplatesBucket,ParameterValue="${PROJECT}-${RAND}" ParameterKey=ProjectName,ParameterValue="${PROJECT}" \
                                                 ParameterKey=BastionEndpoint,ParameterValue="xyz.${RAND}.com" ParameterKey=SslCertificateArn,ParameterValue="${SSL_CERT}" \
                                                 ParameterKey=EcsInstancesKey,ParameterValue="${ECS_KEY}" ParameterKey=BastionKey,ParameterValue="${BASTION_KEY}"
else
    echo "Stack ${PROJECT} exists, update will be executed..."
    aws cloudformation update-stack --stack-name ${PROJECT} \
                                    --capabilities CAPABILITY_NAMED_IAM \
                                    --template-body file://${PROJECT_TEMPLATE} \
                                    --parameters ParameterKey=TemplatesBucket,ParameterValue="${PROJECT}-${RAND}" ParameterKey=ProjectName,ParameterValue="${PROJECT}" \
                                                 ParameterKey=BastionEndpoint,ParameterValue="xyz.${RAND}.com" ParameterKey=SslCertificateArn,ParameterValue="${SSL_CERT}" \
                                                 ParameterKey=EcsInstancesKey,ParameterValue="${ECS_KEY}" ParameterKey=BastionKey,ParameterValue="${BASTION_KEY}"
fi

aws cloudformation describe-stacks --stack-name ${DNS_STACK} &> /dev/null
if [ $? -ne 0 ];then
    echo "Stack ${DNS_STACK} does not exist, create will be executed..."
    aws cloudformation create-stack --stack-name ${DNS_STACK} \
                                    --capabilities CAPABILITY_NAMED_IAM \
                                    --template-body file://${DNS_TEMPLATE} \
                                    --enable-termination-protection \
                                    --parameters ParameterKey=HostedZoneName,ParameterValue="${RAND}.com"
else
    echo "Stack ${DNS_STACK} exists, no action will be executed..."                           
fi