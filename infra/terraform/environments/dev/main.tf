terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project     = "Voting-DevSecOps-Microservices"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "voting-vote",
    "voting-result",
    "voting-worker"
  ]

  force_delete = var.ecr_force_delete
  tags         = local.common_tags
}

module "github_oidc" {
  source = "../../modules/github-oidc"

  github_owner = var.github_owner
  github_repo  = var.github_repo
  role_name    = var.github_actions_role_name

  ecr_repository_arns = values(module.ecr.repository_arns)

  tags = local.common_tags
}