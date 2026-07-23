variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EKS"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for EKS node groups"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "Subnets for EKS control plane ENIs"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS managed node group"
  type        = list(string)
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "access_entries" {
  description = "EKS access entries and namespace-scoped policy associations"
  type        = any
  default     = {}
}
