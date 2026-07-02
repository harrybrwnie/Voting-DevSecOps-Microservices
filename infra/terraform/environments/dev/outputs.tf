output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "github_actions_role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = var.manage_github_oidc ? module.github_oidc[0].role_arn : null
}

output "vpc_id" {
  description = "Dev VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "Dev VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Dev public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Dev private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "Dev NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "eks_cluster_name" {
  description = "Dev EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "Dev EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Dev EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Dev EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_node_security_group_id" {
  description = "Dev EKS node security group ID"
  value       = module.eks.node_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "Dev EKS OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = module.argocd.namespace
}

output "argocd_release_name" {
  description = "Argo CD Helm release name"
  value       = module.argocd.release_name
}

output "argocd_release_status" {
  description = "Argo CD Helm release status"
  value       = module.argocd.release_status
}

output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_admin_secret_name" {
  description = "Kubernetes Secret containing Grafana admin credentials"
  value       = kubernetes_secret.grafana_admin.metadata[0].name
}

output "grafana_admin_user" {
  description = "Grafana admin username"
  value       = var.grafana_admin_user
}

output "grafana_admin_password" {
  description = "Grafana admin password generated for the dev monitoring stack"
  value       = random_password.grafana_admin.result
  sensitive   = true
}
