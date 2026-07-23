output "ecr_repository_urls" {
  description = "Persistent ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "release_role_arn" {
  description = "GitHub Actions build and release role ARN"
  value       = module.github_actions_delivery.release_role_arn
}

output "dev_role_arn" {
  description = "GitHub Actions dev promotion role ARN"
  value       = module.github_actions_delivery.dev_role_arn
}

output "prod_role_arn" {
  description = "GitHub Actions prod promotion role ARN"
  value       = module.github_actions_delivery.prod_role_arn
}

output "release_retention_count" {
  description = "Number of signed releases retained per repository"
  value       = var.release_retention_count
}
