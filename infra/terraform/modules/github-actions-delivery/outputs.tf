output "release_role_arn" {
  description = "Build and release IAM role ARN"
  value       = aws_iam_role.release.arn
}

output "dev_role_arn" {
  description = "Dev promotion IAM role ARN"
  value       = aws_iam_role.environment["dev"].arn
}

output "prod_role_arn" {
  description = "Prod promotion IAM role ARN"
  value       = aws_iam_role.environment["prod"].arn
}
