terraform {
  source = "github.com/geometry-labs/terraform-w3f-eks-cloudwatch-exporter"
}

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals
  cluster = find_in_parent_folders("cluster")
}

dependencies {
  paths = [
    local.cluster]
}

dependency "cluster" {
  config_path = local.cluster
}

inputs = {
  cluster_id = dependency.cluster.outputs.cluster_id
  cluster_oidc_issuer_url = dependency.cluster.outputs.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = dependency.cluster.outputs.oidc_provider_arn
  cloudwatch_exporter_service_account_name = "cloudwatch-exporter-sa"
}
