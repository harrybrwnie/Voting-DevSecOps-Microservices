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
