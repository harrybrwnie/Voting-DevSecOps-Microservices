variable "aws_region" {
  description = "AWS region for Terraform backend resources"
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
}