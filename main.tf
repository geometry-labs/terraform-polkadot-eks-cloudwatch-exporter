variable "cluster_id" {}
variable "region" {}
variable "cloudwatch_exporter_service_account_name" {}
variable "cluster_oidc_provider_arn" {}
variable "environment" {}

resource "helm_release" "cloudwatch_exporter" {
  name       = "prometheus-cloudwatch-exporter-${var.cluster_id}"
  chart      = "prometheus-cloudwatch-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"

  namespace = "kube-system"
  values = [
    templatefile("./values.yaml", {
      irsa_assumable_role                      = module.iam_assumable_role_admin.this_iam_role_arn
      cloudwatch_exporter_service_account_name = var.cloudwatch_exporter_service_account_name
      region                                   = var.region
  })]
}

resource "aws_iam_role" "cloudwatch_exporter" {
  name_prefix        = "${replace(title(var.cluster_id), "/-| /", "")}CwExporter"
  assume_role_policy = data.aws_iam_policy_document.oidc_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_exporter" {
  policy_arn = aws_iam_policy.cloudwatch_exporter.arn
  role       = aws_iam_role.cloudwatch_exporter.name
}

variable "cluster_oidc_issuer_url" {}
data "aws_region" "this" {}

locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cloudwatch-exporter-sa"
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.13.0"
  create_role                   = true
  role_name                     = "cloudwatch-exporter-${var.cluster_id}-${data.aws_region.this.name}"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cloudwatch_exporter.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

resource "aws_iam_policy" "cloudwatch_exporter" {
  name_prefix = "CloudWatchExporterSA"
  description = "Cloudwatch exporter policy for cluster ${var.cluster_id}"
  policy      = data.aws_iam_policy_document.cloudwatch_exporter.json
}

data "aws_iam_policy_document" "cloudwatch_exporter" {
  statement {
    sid    = "CloudWatchExporterSA"
    effect = "Allow"

    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "tag:GetResources"
    ]

    resources = ["*"]
  }
}

locals {
  oidc_list = split("/", var.cluster_oidc_provider_arn)
  oidc_id   = element(local.oidc_list, length(local.oidc_list) - 1)
}

data "aws_iam_policy_document" "oidc_trust_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${data.aws_region.this.name}.amazonaws.com/id/${local.oidc_id}:sub"
      values   = ["system:serviceaccount:kube-system:${var.cloudwatch_exporter_service_account_name}"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.cluster_oidc_provider_arn]
    }
  }
}
