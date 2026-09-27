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

data "aws_iam_policy_document" "dynatrace_topology_inventory" {
  statement {
    sid    = "TopologyInventory"
    effect = "Allow"
    actions = [
      "account:GetAccountInformation",
      "acm-pca:ListCertificateAuthorities",
      "aoss:BatchGetCollection",
      "aoss:ListCollections",
      "apigateway:GET",
      "apprunner:DescribeAutoScalingConfiguration",
      "apprunner:DescribeService",
      "apprunner:DescribeVpcConnector",
      "apprunner:DescribeVpcIngressConnection",
      "apprunner:ListAutoScalingConfigurations",
      "apprunner:ListServices",
      "apprunner:ListTagsForResource",
      "apprunner:ListVpcConnectors",
      "apprunner:ListVpcIngressConnections",
      "athena:GetWorkGroup",
      "athena:ListWorkGroups",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeWarmPool",
      "bedrock:GetAgent",
      "bedrock:GetAgentAlias",
      "bedrock:GetGuardrail",
      "bedrock:GetKnowledgeBase",
      "bedrock:ListAgentAliases",
      "bedrock:ListAgents",
      "bedrock:ListGuardrails",
      "bedrock:ListKnowledgeBases",
      "cloudfront:GetDistribution",
      "cloudfront:ListDistributions",
      "cloudfront:ListTagsForResource",
      "cloudhsm:DescribeClusters",
      "cloudtrail:GetEventSelectors",
      "cloudtrail:GetTrail",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:ListTrails",
      "cloudtrail:LookupEvents",
      "dax:DescribeClusters",
      "dax:DescribeSubnetGroups",
      "directconnect:DescribeConnections",
      "directconnect:DescribeVirtualInterfaces",
      "dms:DescribeReplicationInstances",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeKinesisStreamingDestination",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTables",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeClientVpnEndpoints",
      "ec2:DescribeCustomerGateways",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeEgressOnlyInternetGateways",
      "ec2:DescribeIamInstanceProfileAssociations",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTransitGatewayAttachments",
      "ec2:DescribeTransitGatewayConnects",
      "ec2:DescribeTransitGatewayMulticastDomains",
      "ec2:DescribeTransitGatewayRouteTables",
      "ec2:DescribeTransitGateways",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcEndpointServiceConfigurations",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpnConnections",
      "ec2:DescribeVpnGateways",
      "ecr-public:DescribeRepositories",
      "ecr-public:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecs:DescribeCapacityProviders",
      "ecs:DescribeClusters",
      "ecs:DescribeContainerInstances",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListClusters",
      "ecs:ListContainerInstances",
      "ecs:ListServices",
      "ecs:ListTaskDefinitions",
      "ecs:ListTasks",
      "eks:DescribeCluster",
      "eks:DescribeNodegroup",
      "eks:ListClusters",
      "eks:ListNodegroups",
      "elasticache:DescribeCacheClusters",
      "elasticache:DescribeCacheParameterGroups",
      "elasticache:DescribeCacheParameters",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticache:DescribeServerlessCaches",
      "elasticbeanstalk:DescribeApplications",
      "elasticbeanstalk:DescribeEnvironmentResources",
      "elasticbeanstalk:DescribeEnvironments",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancerPolicies",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "es:DescribeDomains",
      "es:ListDomainNames",
      "events:DescribeEventBus",
      "events:ListEventBuses",
      "firehose:DescribeDeliveryStream",
      "firehose:ListDeliveryStreams",
      "iam:GenerateCredentialReport",
      "iam:GetAccountAuthorizationDetails",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:GetCredentialReport",
      "iam:ListAccountAliases",
      "iam:ListInstanceProfiles",
      "iam:ListMFADevices",
      "iam:ListServerCertificates",
      "kafka:ListClustersV2",
      "kms:DescribeKey",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListKeys",
      "lambda:GetAlias",
      "lambda:GetFunction",
      "lambda:GetPolicy",
      "lambda:ListAliases",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions",
      "logs:DescribeLogGroups",
      "logs:DescribeSubscriptionFilters",
      "mq:DescribeBroker",
      "mq:DescribeConfiguration",
      "mq:ListBrokers",
      "mq:ListConfigurations",
      "organizations:DescribeOrganization",
      "rds:DescribeOptionGroups",
      "rds:ListTagsForResource",
      "redshift-serverless:ListNamespaces",
      "redshift-serverless:ListWorkgroups",
      "redshift:DescribeClusterSubnetGroups",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "route53:GetHostedZone",
      "route53:ListHealthChecks",
      "route53:ListHostedZones",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketVersioning",
      "s3:GetEncryptionConfiguration",
      "s3:ListAllMyBuckets",
      "sns:GetTopicAttributes",
      "sns:ListTopics",
      "sqs:GetQueueAttributes",
      "sqs:ListQueues",
      "states:DescribeStateMachine",
      "states:ListStateMachines",
      "storagegateway:DescribeGatewayInformation",
      "storagegateway:ListGateways",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "wafv2:GetWebACL",
      "wafv2:ListWebACLs"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "dynatrace_monitoring" {
  statement {
    sid    = "CloudWatchMonitoring"
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "dynatrace_additional" {
  statement {
    sid    = "TopologyInventoryAdditional"
    effect = "Allow"
    actions = [
      "acm:ListCertificates",
      "airflow:GetEnvironment",
      "airflow:ListEnvironments",
      "apigateway:GetStage",
      "appstream:DescribeFleets",
      "appstream:ListTagsForResource",
      "appsync:ListGraphqlApis",
      "backup:GetBackupPlan",
      "backup:GetBackupVaultNotifications",
      "backup:ListBackupPlans",
      "backup:ListBackupVaults",
      "cassandra:GetKeyspace",
      "cassandra:GetTable",
      "cassandra:ListKeyspaces",
      "cassandra:ListTables",
      "cassandra:ListTagsForResource",
      "cassandra:Select",
      "codebuild:BatchGetProjects",
      "codebuild:ListProjects",
      "cognito-idp:DescribeUserPool",
      "cognito-idp:ListUserPools",
      "connect:DescribeInstance",
      "connect:ListInstanceStorageConfigs",
      "connect:ListInstances",
      "datasync:DescribeTask",
      "datasync:ListTasks",
      "ec2:DescribeFlowLogs",
      "ec2:DescribeIpamPools",
      "ec2:DescribeIpamScopes",
      "ec2:DescribeIpams",
      "elasticmapreduce:DescribeCluster",
      "emr-containers:DescribeManagedEndpoint",
      "emr-containers:DescribeVirtualCluster",
      "emr-serverless:GetApplication",
      "events:ListRules",
      "execute-api:GetStage",
      "fsx:DescribeFileSystems",
      "fsx:DescribeStorageVirtualMachines",
      "fsx:DescribeVolumes",
      "globalaccelerator:ListAccelerators",
      "globalaccelerator:ListTagsForResource",
      "glue:GetJobs",
      "kafka:DescribeClusterV2",
      "kafka:DescribeConfiguration",
      "kafka:DescribeVpcConnection",
      "kafka:ListConfigurations",
      "kafka:ListVpcConnections",
      "kafkaconnect:DescribeConnector",
      "kafkaconnect:ListConnectors",
      "kinesis:DescribeStreamSummary",
      "kinesis:ListStreams",
      "kinesisanalytics:DescribeApplication",
      "kinesisanalytics:ListApplications",
      "kinesisanalytics:ListTagsForResource",
      "logs:DescribeDeliveryDestinations",
      "network-firewall:DescribeFirewall",
      "network-firewall:DescribeFirewallPolicy",
      "network-firewall:ListFirewallPolicies",
      "network-firewall:ListFirewalls",
      "rds:DescribeDBClusterSnapshots",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:DescribeDBSnapshots",
      "rds:DescribeDBSubnetGroups",
      "route53:GetHealthCheck",
      "route53resolver:ListResolverEndpoints",
      "s3:ListBuckets",
      "sagemaker:DescribeEndpoint",
      "sagemaker:DescribeFeatureGroup",
      "sagemaker:DescribeInferenceComponent",
      "sagemaker:DescribeLabelingJob",
      "sagemaker:DescribePipeline",
      "sagemaker:ListEndpoints",
      "sagemaker:ListFeatureGroups",
      "sagemaker:ListInferenceComponents",
      "sagemaker:ListLabelingJobs",
      "sagemaker:ListPipelines"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "dynatrace_topology" {
  name   = "dynatrace-topology-inventory"
  role   = aws_iam_role.dynatrace.id
  policy = data.aws_iam_policy_document.dynatrace_topology_inventory.json
}

resource "aws_iam_role_policy" "dynatrace_cloudwatch" {
  name   = "dynatrace-cloudwatch-monitoring"
  role   = aws_iam_role.dynatrace.id
  policy = data.aws_iam_policy_document.dynatrace_monitoring.json
}

resource "aws_iam_role_policy" "dynatrace_additional" {
  name   = "dynatrace-additional-topology"
  role   = aws_iam_role.dynatrace.id
  policy = data.aws_iam_policy_document.dynatrace_additional.json
}
