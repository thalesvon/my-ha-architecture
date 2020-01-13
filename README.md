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