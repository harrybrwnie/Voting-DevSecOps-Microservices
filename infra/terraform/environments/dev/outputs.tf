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

output "voting_namespace" {
  description = "Voting application namespace"
  value       = kubernetes_namespace.voting.metadata[0].name
}

output "voting_prod_namespace" {
  description = "Production voting application namespace"
  value       = kubernetes_namespace.voting_prod.metadata[0].name
}

output "postgres_secret_name" {
  description = "Kubernetes Secret containing PostgreSQL credentials"
  value       = kubernetes_secret.postgres.metadata[0].name
}

output "shared_delivery_roles" {
  description = "Persistent GitHub Actions delivery role ARNs"
  value = {
    release = data.terraform_remote_state.shared.outputs.release_role_arn
    dev     = data.terraform_remote_state.shared.outputs.dev_role_arn
    prod    = data.terraform_remote_state.shared.outputs.prod_role_arn
  }
}

output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "monitoring_release_name" {
  description = "kube-prometheus-stack Helm release name"
  value       = helm_release.monitoring.name
}

output "monitoring_release_status" {
  description = "kube-prometheus-stack Helm release status"
  value       = helm_release.monitoring.status
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
