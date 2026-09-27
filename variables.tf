variable "aws_region" {
  description = "AWS region to use for the Terraform AWS provider."
  type        = string
  default     = "eu-west-2"
}

variable "tfc_organization" {
  description = "Terraform Cloud organization that contains the dynatrace-prd-application workspace."
  type        = string
  default     = "smdevops96_org"
}

variable "tfc_hostname" {
  description = "Terraform Cloud hostname."
  type        = string
  default     = "app.terraform.io"
}

variable "tfe_secret_arn" {
  description = "ARN of the AWS Secrets Manager JSON secret containing the Terraform Cloud token under the TFE_TOKEN key."
  type        = string
  default     = "arn:aws:secretsmanager:eu-west-2:899045892145:secret:tfe-secret-1zXi4G"
}

variable "dynatrace_workspace_name" {
  description = "Terraform Cloud workspace containing the aws_connections output from the Dynatrace AWS connection setup."
  type        = string
  default     = "dynatrace-prd-application"
}

variable "dynatrace_aws_account_id" {
  description = "Dynatrace AWS account ID used in the trust relationship."
  type        = string
  default     = "314146291599"
}

variable "role_name" {
  description = "Name of the IAM role to create for Dynatrace."
  type        = string
  default     = "dynatrace-aws-connection"
}
