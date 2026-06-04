variable "namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version. Null means latest available chart version."
  type        = string
  default     = null
}