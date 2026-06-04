variable "github_owner" {
  description = "GitHub owner or organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs allowed for GitHub Actions"
  type        = list(string)
}

variable "github_oidc_thumbprint" {
  description = "GitHub OIDC thumbprint"
  type        = string
  default     = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}