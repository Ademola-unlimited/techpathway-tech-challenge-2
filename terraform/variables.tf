
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for AWS resources"
  type        = string
  default     = "techpathway-challenge-2"
}

variable "vpc_cidr" {
  description = "CIDR block for our VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones for deployment"
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}
