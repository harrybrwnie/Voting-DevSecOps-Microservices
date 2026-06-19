variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Argo CD Helm chart version. Null means latest available chart version."
  type        = string
  default     = null
}

variable "monitoring_namespace" {
  description = "Namespace where monitoring components will be installed"
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_secret_name" {
  description = "Kubernetes Secret name that stores Grafana admin credentials"
  type        = string
  default     = "grafana-admin-credentials"
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}
