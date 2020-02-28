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

[x] BastionbBootstrap script to update bastion DNS on public hosted zone

[ ] Launch jenkins on secondary account.

[ ] Create AWS Config rules for s3 buckets with public access and ec2 instances with ssh open to internet.

[ ] ApiService.Properties.DeploymentController.Type is configured to ECS right now but it is planned to implement blue/green deployment using type CODE_DEPLOY

# To upload docker image

```shell
$(aws ecr get-login --no-include-email)
docker tag hello 358441290192.dkr.ecr.eu-west-1.amazonaws.com/my-ha-architecture/api:latest
docker push 358441290192.dkr.ecr.eu-west-1.amazonaws.com/my-ha-architecture/api:latest
```

# Resource created outside cloudformation

- SSL Certificates requested direclty from console to avoid stack to be stuck in [CREATE_IN_PROGRESS][1]

# TODO 


[1]:https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-certificatemanager-certificate.html