# Notes for future implementations

For HTTP to HTTPS redirection on ALB port 80 listerner, use:

```yaml
AlbHTTPListener:
    Type: "AWS::ElasticLoadBalancingV2::Listener"
    Properties:
      DefaultActions:
        - 
          RedirectConfig:
            Host: "#{host}"
            Path: "/#{path}"
            Port: 443
            Protocol: "HTTPS"
            Query: "#{query}"
            StatusCode: HTTP_301
          Type: redirect
      LoadBalancerArn: !Ref AppLoadBalancer
      Port: 80
      Protocol: HTTP
```

# Next Steps

[x] Add internet route on VPC route route table

[ ] ApiService.Properties.DeploymentController.Type is configured to ECS right now but it is planned to implement blue/green deployment using type CODE_DEPLOY

# To upload docker image

```shell
$(aws ecr get-login --no-include-email)
docker tag hello acc_id.dkr.ecr.REGION.amazonaws.com/my-ha-architecture/api:latest
docker push acc_id.dkr.ecr.REGION.amazonaws.com/my-ha-architecture/api:latest
```

# TODO 
BastionbBootstrap script to update bastion DNS on public hosted zone.

```bash
#!/bin/bash
          
set -eux
yum install -y aws-cfn-bootstrap
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource BastionAutoScalingGroup --region ${AWS::Region}

export PATH=/usr/local/bin:$PATH
yum -y install jq
easy_install pip
pip install awscli
aws configure set default.region ${AWS::Region}
HOSTED_ZONE_ID='ZGTKXKO161TQU'
DNS_NAME='cluster1.dev.boomcredit.mx.local.'
DNS_TYPE='A'
DNS_TTL=300
DNS_VALUE=$(curl -sf http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOF > /home/ec2-user/dns.json
{
    "Comment": "Internal IP for spot-cluster", 
    "Changes": [
        {
            "Action": "UPSERT", 
            "ResourceRecordSet": {
                "Name": "$DNS_NAME", 
                "Type": "$DNS_TYPE", 
                "TTL": $DNS_TTL, 
                "ResourceRecords": [
                    {
                        "Value": "$DNS_VALUE"
                    }
                ]
            }
        }
    ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file:///home/ec2-user/dns.json
```