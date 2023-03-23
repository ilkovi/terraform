variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region for deployment."
}

variable "vpc_prefix" {
  default     = "172.16.0.0/16"
  description = "AWS prefix in CIDR format."
}

variable "subnet_prefix" {
  default     = "172.16.10.0/24"
  description = "AWS Subnet prefix in CIDR format."
}
