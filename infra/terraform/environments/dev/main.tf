terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket       = "h4rrybrwnie-voting-tfstate-911540681678-us-east-1"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0, < 3.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0, < 3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster_auth" "dev" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.dev.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.dev.token
  }
}

locals {
  common_tags = {
    Project     = "Voting-DevSecOps-Microservices"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name = "voting-dev"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  control_plane_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = var.eks_node_instance_types
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size
  node_desired_size   = var.eks_node_desired_size

  tags = local.common_tags
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

module "argocd" {
  source = "../../modules/argocd"

  namespace     = var.argocd_namespace
  chart_version = var.argocd_chart_version

  depends_on = [module.eks]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace

    labels = {
      "app.kubernetes.io/name"       = "monitoring"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  depends_on = [module.eks]
}

resource "random_password" "grafana_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = var.grafana_admin_secret_name
    namespace = kubernetes_namespace.monitoring.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "grafana"
      "app.kubernetes.io/component"  = "admin-credentials"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  type = "Opaque"

  data = {
    admin-user     = var.grafana_admin_user
    admin-password = random_password.grafana_admin.result
  }
}

module "github_oidc" {
  count = var.manage_github_oidc ? 1 : 0

  source = "../../modules/github-oidc"

  github_owner = var.github_owner
  github_repo  = var.github_repo
  role_name    = var.github_actions_role_name

  ecr_repository_arns = values(module.ecr.repository_arns)

  tags = local.common_tags
}
