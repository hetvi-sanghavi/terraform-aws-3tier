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
| [aws_db_instance.three_tier_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | n/a | `any` | n/a | yes |
| <a name="input_db_identifier"></a> [db\_identifier](#input\_db\_identifier) | n/a | `any` | n/a | yes |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | n/a | `any` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | n/a | `any` | n/a | yes |
| <a name="input_db_storage"></a> [db\_storage](#input\_db\_storage) | n/a | `any` | n/a | yes |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | n/a | `any` | n/a | yes |
| <a name="input_dbpassword"></a> [dbpassword](#input\_dbpassword) | n/a | `any` | n/a | yes |
| <a name="input_dbuser"></a> [dbuser](#input\_dbuser) | n/a | `any` | n/a | yes |
| <a name="input_rds_sg"></a> [rds\_sg](#input\_rds\_sg) | n/a | `any` | n/a | yes |
| <a name="input_skip_db_snapshot"></a> [skip\_db\_snapshot](#input\_skip\_db\_snapshot) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | n/a |
