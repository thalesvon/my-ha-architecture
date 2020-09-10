# Nested Stack simple practice

# Intrusctions

1 - Some resources are required to be unique, such as S3 Bucket and Route 53 hosted zone. In order to properly create stack change the variable `RAND` on `helper.sh` with an unique value. A random value can be generated with `openssl rand -hex 6`.

3 - Create Ec2 key pairs for bastion and Ecs Container Instances:

```bash
export BASTION_KEY="BastionKey"
export ECS_KEY="EcsInstancesKey"
aws ec2 create-key-pair --key-name ${BASTION_KEY} --query "KeyMaterial" --output text > "${BASTION_KEY}".pem
aws ec2 create-key-pair --key-name ${ECS_KEY} --query "KeyMaterial" --output text > "${ECS_KEY}".pem
```
2 - Once RAND is unique:

```bash
$ chmod +x ./helper.sh
$ ./helper.sh
```

# Next Steps

[x] Add internet route on VPC route route table

[x] BastionbBootstrap script to update bastion DNS on public hosted zone

[ ] Launch jenkins on secondary account.

[ ] Create AWS Config rules for s3 buckets with public access and ec2 instances with ssh open to internet.

[ ] ApiService.Properties.DeploymentController.Type is configured to ECS right now but it is planned to implement blue/green deployment using type CODE_DEPLOY


# Resource created outside cloudformation

- SSL Certificates requested direclty from console to avoid stack to be stuck in [CREATE_IN_PROGRESS][1]

# TODO 

- Diagram of what CFN builds



[1]:https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-certificatemanager-certificate.html
