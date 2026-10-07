variable "aws_region" {
  type        = string
  description = "AWS region where the S3 bucket will be created."
  default     = "ap-southeast-2"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique name of the S3 bucket."
}

variable "environment" {
  type        = string
  description = "Environment tag applied to resources."
  default     = "dev"
}
