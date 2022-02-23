module "exporter" {
  source                                   = "../.."
  cluster_id                               = module.eks.cluster_id
  cluster_oidc_issuer_url                  = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn                = module.eks.oidc_provider_arn
  cloudwatch_exporter_service_account_name = "cloudwatch-exporter-sa"
}

# Example code - This is simply demonstrates the outputs from the EKS module that you would need to deploy this resource
# The below would need further modification to actually work.  Requires https://github.com/terraform-aws-modules/terraform-aws-eks#irsa-integration

module "vpc_cni_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "example"
  cluster_version = "1.21"

  cluster_addons = {
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  eks_managed_node_group_defaults = {
    # We are using the IRSA created below for permissions
    # This is a better practice as well so that the nodes do not have the permission,
    # only the VPC CNI addon will have the permission
    iam_role_attach_cni_policy = false
  }

  eks_managed_node_groups = {
    default = {}
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
