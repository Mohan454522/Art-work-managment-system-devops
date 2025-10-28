variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_account_id" {
  type = string
  description = "Your AWS account ID"
}

variable "ecr_repo" {
  type = string
  description = "ECR repository name"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type        = string
  description = "Existing AWS key pair name for SSH (optional)"
  default     = ""
}
