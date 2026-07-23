variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_oidc_provider_arn" {
  description = "ARN of the existing GitHub Actions OIDC provider"
  type        = string
}

variable "release_role_name" {
  description = "IAM role used to build and publish immutable releases"
  type        = string
  default     = "github-actions-voting-release"
}

variable "dev_role_name" {
  description = "IAM role used by jobs protected by the dev GitHub Environment"
  type        = string
  default     = "github-actions-voting-dev"
}

variable "prod_role_name" {
  description = "IAM role used by jobs protected by the prod GitHub Environment"
  type        = string
  default     = "github-actions-voting-prod"
}

variable "ecr_repository_arns" {
  description = "ECR repositories used for release images and Cosign signatures"
  type        = list(string)
}

variable "ssm_parameter_arn_prefix" {
  description = "ARN prefix ending in parameter/voting"
  type        = string
}

variable "eks_cluster_arn" {
  description = "ARN of the shared dev/prod EKS cluster"
  type        = string
}

variable "tags" {
  description = "Tags applied to IAM resources"
  type        = map(string)
  default     = {}
}
