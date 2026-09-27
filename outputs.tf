output "dynatrace_object_id" {
  description = "Object ID retrieved from the aws_connections output."
  value       = local.dynatrace_object_id
  sensitive   = true
}

output "dynatrace_external_id" {
  description = "External ID used in the role trust policy."
  value       = local.dynatrace_external_id
  sensitive   = true
}

output "dynatrace_role_arn" {
  description = "ARN of the IAM role created for Dynatrace."
  value       = aws_iam_role.dynatrace.arn
}

output "dynatrace_role_name" {
  description = "Name of the IAM role created for Dynatrace."
  value       = aws_iam_role.dynatrace.name
}
