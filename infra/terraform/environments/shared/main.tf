terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket       = "h4rrybrwnie-voting-tfstate-911540681678-us-east-1"
    key          = "shared/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  common_tags = {
    Project     = "Voting-DevSecOps-Microservices"
    Environment = "shared"
    ManagedBy   = "Terraform"
  }

  eks_cluster_arn = "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"
  ssm_arn_prefix  = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/voting"
}

module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "voting-vote",
    "voting-result",
    "voting-worker"
  ]

  force_delete         = false
  image_tag_mutability = "IMMUTABLE"
  max_image_count      = var.release_retention_count
  tags                 = local.common_tags
}

module "github_actions_delivery" {
  source = "../../modules/github-actions-delivery"

  github_owner             = var.github_owner
  github_repo              = var.github_repo
  github_oidc_provider_arn = data.aws_iam_openid_connect_provider.github.arn
  ecr_repository_arns      = values(module.ecr.repository_arns)
  ssm_parameter_arn_prefix = local.ssm_arn_prefix
  eks_cluster_arn          = local.eks_cluster_arn

  tags = local.common_tags
}
