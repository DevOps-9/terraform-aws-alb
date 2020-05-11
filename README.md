<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS ALB
</h1>

<p align="center" style="font-size: 1.2rem;">
    This terraform module is used to create ALB on AWS.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v0.12-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-aws-alb'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AWS+ALB&url=https://github.com/clouddrove/terraform-aws-alb'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AWS+ALB&url=https://github.com/clouddrove/terraform-aws-alb'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure.

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies:

- [Terraform 0.12](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-alb/releases).


Here are examples of how you can use this module in your inventory structure:
### alb Example
```hcl
  module "alb" {
    source                     = "git::https://github.com/clouddrove/terraform-aws-alb.git?ref=tags/0.12.6"
    name                       = "alb"
    application                = "clouddrove"
    environment                = "test"
    label_order                = ["environment", "application", "name"]
    internal                   = false
    load_balancer_type         = "application"
    instance_count             = module.ec2.instance_count
    security_groups            = [module.ssh.security_group_ids, module.http-https.security_group_ids]
    subnets                    = module.public_subnets.public_subnet_id
    enable_deletion_protection = false
    target_id                  = module.ec2.instance_id
    vpc_id                     = module.vpc.vpc_id
    https_enabled              = true
    http_enabled               = true
    https_port                 = 443
    listener_type              = "forward"
    listener_certificate_arn   = "arn:aws:acm:eu-west-1:924144197303:certificate/0418d2ba-91f7-4196-991b-28b5c60cd4cf"
    target_group_port          = 80
    target_groups  = [
      {
        backend_protocol     = "HTTP"
        backend_port         = 80
        target_type          = "instance"
        deregistration_delay = 300
        health_check = {
          enabled             = true
          interval            = 30
          path                = "/"
          port                = "traffic-port"
          healthy_threshold   = 3
          unhealthy_threshold = 3
          timeout             = 10
          protocol            = "HTTP"
          matcher             = "200-399"
        }
      }
    ]
  }
```

### nlb Example
```hcl
  module "alb" {
    source                     = "git::https://github.com/clouddrove/terraform-aws-alb.git?ref=tags/0.12.6"
    name                       = "nlb"
    application                = "clouddrove"
    environment                = "test"
    label_order                = ["environment", "application", "name"]
    internal                   = false
    load_balancer_type         = "application"
    instance_count             = module.ec2.instance_count
    subnets                    = module.public_subnets.public_subnet_id
    enable_deletion_protection = false
    target_id                  = module.ec2.instance_id
    vpc_id                     = module.vpc.vpc_id
    http_tcp_listeners = [
      {
        port               = 80
        protocol           = "TCP"
        target_group_index = 0
      },
    ]

    https_listeners = [
      {
        port               = 443
        protocol           = "TLS"
        certificate_arn    = "arn:aws:acm:eu-west-1:924144197303:certificate/0418d2ba-91f7-4196-991b-28b5c60cd4cf"
        target_group_index = 1
      },
    ]

    target_groups = [
      {
        backend_protocol = "TCP"
        backend_port     = 80
        target_type      = "instance"
      },
      {
        backend_protocol = "TLS"
        backend_port     = 443
        target_type      = "instance"
      },
    ]
  }
```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_logs | Access logs Enable or Disable. | bool | `"false"` | no |
| allocation\_id | The allocation ID of the Elastic IP address. | string | `""` | no |
| application | Application \(e.g. `cd` or `clouddrove`\). | string | `""` | no |
| attributes | Additional attributes \(e.g. `1`\). | list | `<list>` | no |
| delimiter | Delimiter to be used between `organization`, `environment`, `name` and `attributes`. | string | `"-"` | no |
| drop\_invalid\_header\_fields | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer \(true\) or routed to targets \(false\). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application. | bool | `"false"` | no |
| enable | If true, create alb. | bool | `"true"` | no |
| enable\_cross\_zone\_load\_balancing | Indicates whether cross zone load balancing should be enabled in application load balancers. | bool | `"false"` | no |
| enable\_deletion\_protection | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | string | `""` | no |
| enable\_http2 | Indicates whether HTTP/2 is enabled in application load balancers. | bool | `"true"` | no |
| environment | Environment \(e.g. `prod`, `dev`, `staging`\). | string | `""` | no |
| http\_enabled | A boolean flag to enable/disable HTTP listener. | bool | `"true"` | no |
| http\_listener\_type | The type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc. | string | `"redirect"` | no |
| http\_port | The port on which the load balancer is listening. like 80 or 443. | number | `"80"` | no |
| http\_tcp\_listeners | A list of maps describing the HTTP listeners for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index \(defaults to 0\) | list(map(string)) | `<list>` | no |
| https\_enabled | A boolean flag to enable/disable HTTPS listener. | bool | `"true"` | no |
| https\_listeners | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy \(defaults to ELBSecurityPolicy-2016-08\), target\_group\_index \(defaults to 0\) | list(map(string)) | `<list>` | no |
| https\_port | The port on which the load balancer is listening. like 80 or 443. | number | `"443"` | no |
| idle\_timeout | The time in seconds that the connection is allowed to be idle. | number | `"60"` | no |
| instance\_count | The count of instances. | number | `"0"` | no |
| internal | If true, the LB will be internal. | string | `""` | no |
| ip\_address\_type | The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. | string | `"ipv4"` | no |
| label\_order | Label order, e.g. `name`,`application`. | list | `<list>` | no |
| listener\_certificate\_arn | The ARN of the SSL server certificate. Exactly one certificate is required if the protocol is HTTPS. | string | `""` | no |
| listener\_protocol | The protocol for connections from clients to the load balancer. Valid values are TCP, HTTP and HTTPS. Defaults to HTTP. | string | `"HTTPS"` | no |
| listener\_ssl\_policy | The security policy if using HTTPS externally on the load balancer. \[See\]\(https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html\). | string | `"ELBSecurityPolicy-2016-08"` | no |
| listener\_type | The type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc. | string | `"forward"` | no |
| load\_balancer\_create\_timeout | Timeout value when creating the ALB. | string | `"10m"` | no |
| load\_balancer\_delete\_timeout | Timeout value when deleting the ALB. | string | `"10m"` | no |
| load\_balancer\_type | The type of load balancer to create. Possible values are application or network. The default value is application. | string | `""` | no |
| load\_balancer\_update\_timeout | Timeout value when updating the ALB. | string | `"10m"` | no |
| log\_bucket\_name | S3 bucket \(externally created\) for storing load balancer access logs. Required if logging\_enabled is true. | string | `""` | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | string | `"anmol@clouddrove.com"` | no |
| name | Name  \(e.g. `app` or `cluster`\). | string | `""` | no |
| security\_groups | A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application. | list | `<list>` | no |
| status\_code | The HTTP redirect code. The redirect is either permanent \(HTTP\_301\) or temporary \(HTTP\_302\). | string | `"HTTP_301"` | no |
| subnet\_id | The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone. | string | `""` | no |
| subnet\_mapping | A list of subnet mapping blocks describing subnets to attach to network load balancer | list(map(string)) | `<list>` | no |
| subnets | A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value will for load balancers of type network will force a recreation of the resource. | list | `<list>` | no |
| tags | Additional tags \(e.g. map\(`BusinessUnit`,`XYZ`\). | map | `<map>` | no |
| target\_group\_port | The port on which targets receive traffic, unless overridden when registering a specific target. | string | `"80"` | no |
| target\_groups | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port. Optional key/values are in the target\_groups\_defaults variable. | any | `<list>` | no |
| target\_id | The ID of the target. This is the Instance ID for an instance, or the container ID for an ECS container. If the target type is ip, specify an IP address. | list | n/a | yes |
| vpc\_id | The identifier of the VPC in which to create the target group. | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the ALB. |
| arn\_suffix | The ARN suffix of the ALB. |
| dns\_name | DNS name of ALB. |
| http\_listener\_arn | The ARN of the HTTP listener. |
| https\_listener\_arn | The ARN of the HTTPS listener. |
| listener\_arns | A list of all the listener ARNs. |
| main\_target\_group\_arn | The main target group ARN. |
| name | The ARN suffix of the ALB. |
| tags | A mapping of tags to assign to the resource. |
| zone\_id | The ID of the zone which ALB is provisioned. |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system.

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-aws-alb/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-aws-alb)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
