
# terraform-polkadot-eks-cloudwatch-exporter

Terraform module to deploy a cloudwatch exporter on an EKS cluster for monitoring clusters for the Web3 Foundation ecosystem including polkadot and kusama. Creates an IAM assumable role with permissions to pull cloudwatch data that can be assumed by a service account within kubernetes. Used along with prometheus configs from [substrate-meta](https://github.com/geometry-labs/substrate-meta/tree/main/prometheus) repo. 

Includes some examples for how to deploy but in practice it is deployed in via terragrunt. Requires outputs from an EKS cluster terraform module with IRSA enabled.  

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| iam_assumable_role_admin | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 3.13.0 |

## Resources

| Name |
|------|
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudwatch\_exporter\_service\_account\_name | n/a | `any` | n/a | yes |
| cluster\_id | n/a | `any` | n/a | yes |
| cluster\_oidc\_issuer\_url | n/a | `any` | n/a | yes |
| cluster\_oidc\_provider\_arn | n/a | `any` | n/a | yes |
| environment | n/a | `any` | n/a | yes |
| region | n/a | `any` | n/a | yes |

## Outputs

No output.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Geometry Labs](github.com/geometry-labs)

## License

Apache 2 Licensed. See LICENSE for full details.
