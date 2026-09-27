terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.62"
    }
  }

  cloud {
    organization = "smdevops96_org"
    workspaces {
      tags = ["aws", "iam"]
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "tfe" {
  hostname = var.tfc_hostname
  token    = local.tfe_token
}

locals {
  tfe_token = trimspace(jsondecode(data.aws_secretsmanager_secret_version.tfe_token.secret_string)["TFE_TOKEN"])
}

# Read the JSON secret containing the TFE_TOKEN key from AWS Secrets Manager
# Secret ARN provided in the environment / variable

data "aws_secretsmanager_secret_version" "tfe_token" {
  secret_id = var.tfe_secret_arn
}
