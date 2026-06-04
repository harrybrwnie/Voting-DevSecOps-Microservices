variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "github_owner" {
  description = "GitHub owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_actions_role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
}

variable "ecr_force_delete" {
  description = "Whether to force delete ECR repositories"
  type        = bool
  default     = false
}