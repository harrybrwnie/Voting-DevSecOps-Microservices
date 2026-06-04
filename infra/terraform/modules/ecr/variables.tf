variable "repository_names" {
    description = "List of ECR repository names"
    type = list(string)
}

variable "force_delete" {
    description = "Whether to force delete ECR repositories"
    type = bool
    default = false
}

variable "tags" {
    description = "Common tag for ECR repositories"
    type = map(string)
    default = {}
}