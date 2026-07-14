variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "github_owner" {
  description = "GitHub owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_actions_role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
}

variable "manage_github_oidc" {
  description = "Whether Terraform should manage the GitHub Actions OIDC provider and ECR push role. Keep false when these were created manually."
  type        = bool
  default     = false
}

variable "ecr_force_delete" {
  description = "Whether to force delete ECR repositories"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the dev VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for the dev VPC"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway for private subnet egress"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway"
  type        = bool
  default     = false
}

variable "eks_cluster_name" {
  description = "EKS cluster name for dev"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version for dev EKS cluster"
  type        = string
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS managed node group"
  type        = list(string)
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
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

variable "monitoring_release_name" {
  description = "Helm release name for kube-prometheus-stack"
  type        = string
  default     = "monitoring"
}

variable "monitoring_chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "86.3.1"
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
