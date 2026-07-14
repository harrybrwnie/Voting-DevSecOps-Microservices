variable "repository_names" {
  description = "List of ECR repository names"
  type        = list(string)
}

variable "force_delete" {
  description = "Whether to force delete ECR repositories"
  type        = bool
  default     = false
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

variable "max_image_count" {
  description = "Maximum number of images retained per repository"
  type        = number
  default     = 20

  validation {
    condition     = var.max_image_count >= 3
    error_message = "max_image_count must be at least 3 to preserve rollback capacity."
  }
}

variable "tags" {
  description = "Common tag for ECR repositories"
  type        = map(string)
  default     = {}
}
