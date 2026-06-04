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