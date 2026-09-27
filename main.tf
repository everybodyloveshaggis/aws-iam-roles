data "tfe_outputs" "dynatrace" {
  organization = var.tfc_organization
  workspace    = var.dynatrace_workspace_name
}

locals {
  aws_connections = try(data.tfe_outputs.dynatrace.values["aws_connections"], {})

  dynatrace_connection = try(
    values(local.aws_connections)[0],
    {}
  )

  dynatrace_object_id = try(
    local.dynatrace_connection.object_id,
    local.dynatrace_connection.objectId,
    ""
  )

  dynatrace_external_id = try(
    local.dynatrace_connection.sts.externalId,
    local.dynatrace_connection.sts["externalId"],
    local.dynatrace_connection["sts"]["externalId"],
    local.dynatrace_object_id,
    ""
  )
}

data "aws_iam_policy_document" "dynatrace_assume_role" {
  statement {
    sid     = "AllowDynatraceToAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.dynatrace_aws_account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [local.dynatrace_external_id]
    }
  }
}

resource "aws_iam_role" "dynatrace" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.dynatrace_assume_role.json

  tags = {
    Name           = var.role_name
    Dynatrace      = "true"
    ManagedBy      = "Terraform"
    TerraformCloud = "true"
  }
}

data "aws_iam_policy_document" "dynatrace_role_policy" {
  statement {
    sid    = "ReadOnlyMonitoring"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "elasticloadbalancing:Describe*",
      "autoscaling:Describe*",
      "rds:Describe*",
      "elasticache:Describe*",
      "lambda:List*",
      "lambda:GetFunction",
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
      "sns:ListTopics",
      "sns:GetTopicAttributes",
      "sqs:ListQueues",
      "sqs:GetQueueAttributes"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "dynatrace" {
  name   = "dynatrace-readonly-policy"
  role   = aws_iam_role.dynatrace.id
  policy = data.aws_iam_policy_document.dynatrace_role_policy.json
}
