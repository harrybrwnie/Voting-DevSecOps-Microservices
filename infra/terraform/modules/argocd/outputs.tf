output "namespace" {
  description = "Argo CD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "release_name" {
  description = "Argo CD Helm release name"
  value       = helm_release.argocd.name
}

output "release_status" {
  description = "Argo CD Helm release status"
  value       = helm_release.argocd.status
}