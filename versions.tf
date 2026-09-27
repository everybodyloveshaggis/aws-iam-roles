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
    organization = "everybodyloveshaggis"
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
}
