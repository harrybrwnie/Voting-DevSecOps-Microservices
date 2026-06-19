terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket       = "h4rrybrwnie-voting-tfstate-911540681678-us-east-1"
    key          = "dev-k8s/terraform.tfstate"
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

data "terraform_remote_state" "dev" {
  backend = "s3"

  config = {
    bucket = "h4rrybrwnie-voting-tfstate-911540681678-us-east-1"
    key    = "dev/terraform.tfstate"
    region = var.aws_region
  }
}

data "aws_eks_cluster" "dev" {
  name = data.terraform_remote_state.dev.outputs.eks_cluster_name
}

data "aws_eks_cluster_auth" "dev" {
  name = data.terraform_remote_state.dev.outputs.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.dev.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.dev.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.dev.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.dev.token
  }
}

module "argocd" {
  source = "../../modules/argocd"

  namespace     = var.argocd_namespace
  chart_version = var.argocd_chart_version
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace

    labels = {
      "app.kubernetes.io/name"       = "monitoring"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
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
