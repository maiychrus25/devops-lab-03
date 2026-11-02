variable "region" {
  description = "Selected AWS Region of this project"
  type        = string
  default     = "ap-southeast-2"

  validation {
    condition     = var.region == "ap-southeast-2"
    error_message = "This project must use ap-southeast-2."
  }
}

variable "instance_type" {
  description = "EC2 instance type verified as Free Tier eligible for this project"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Amazon Linux 2023 x86_64 AMI in ap-southeast-2, verified through the AWS public SSM parameter"
  type        = string
  default     = "ami-062900c135ab91582"
}

variable "key_name" {
  description = "SSH key name; the public key must exist at ~/.ssh/<key_name>.pem.pub"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]+$", var.key_name))
    error_message = "Use only English letters, digits, underscores, and hyphens in the key name."
  }
}

variable "s3_bucket_prefix" {
  description = "S3 bucket prefix; a random suffix makes the final name globally unique"
  type        = string
  default     = "lab3-dtc235180104"
}

variable "environment" {
  description = "Environment tag for this lab"
  type        = string
  default     = "dev"
}

variable "ssh_allowed_cidr" {
  description = "Operator public IPv4 address as a single-host CIDR; refresh this value if the network changes"
  type        = string
  default     = "104.28.243.55/32"

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr)) && endswith(var.ssh_allowed_cidr, "/32")
    error_message = "SSH must be restricted to one valid IPv4 /32, not the public internet."
  }
}
