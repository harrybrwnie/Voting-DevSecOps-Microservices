variable "aws_region" {
  description = "AWS region for persistent delivery resources"
  type        = string
  default     = "us-east-1"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "harrybrwnie"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "Voting-DevSecOps-Microservices"
}

variable "eks_cluster_name" {
  description = "Name of the ephemeral EKS cluster used by dev and prod"
  type        = string
  default     = "voting-dev-eks"
}

variable "release_retention_count" {
  description = "Number of signed releases retained in each ECR repository"
  type        = number
  default     = 20

  validation {
    condition     = var.release_retention_count >= 3
    error_message = "release_retention_count must be at least 3."
  }
}
