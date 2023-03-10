## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.three_tier_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.three_tier_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.three_tier_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_asg"></a> [app\_asg](#input\_app\_asg) | n/a | `any` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | n/a | `any` | n/a | yes |
| <a name="input_lb_sg"></a> [lb\_sg](#input\_lb\_sg) | n/a | `any` | n/a | yes |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | n/a | `any` | n/a | yes |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | n/a | `any` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_tg_port"></a> [tg\_port](#input\_tg\_port) | n/a | `any` | n/a | yes |
| <a name="input_tg_protocol"></a> [tg\_protocol](#input\_tg\_protocol) | n/a | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns"></a> [alb\_dns](#output\_alb\_dns) | n/a |
| <a name="output_lb_endpoint"></a> [lb\_endpoint](#output\_lb\_endpoint) | n/a |
| <a name="output_lb_tg"></a> [lb\_tg](#output\_lb\_tg) | n/a |
| <a name="output_lb_tg_name"></a> [lb\_tg\_name](#output\_lb\_tg\_name) | n/a |
