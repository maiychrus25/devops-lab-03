terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region              = var.region
  allowed_account_ids = ["145847015645"]

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Course      = "DevOps-Bai3"
      StudentId   = "DTC235180104"
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "lab_key" {
  key_name   = var.key_name
  public_key = file(pathexpand("~/.ssh/${var.key_name}.pem.pub"))
}

resource "aws_instance" "lab_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.lab_key.key_name
  vpc_security_group_ids      = [aws_security_group.lab_sg.id]
  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "Lab3-Terraform-Server"
  }
}

resource "aws_security_group" "lab_sg" {
  name        = "lab3-terraform-sg-dtc235180104"
  description = "Lab 3: restricted SSH and public HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from the operator IPv4 address"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lab3-SG"
  }
}

resource "aws_s3_bucket" "lab_bucket" {
  bucket = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "lab_bucket_versioning" {
  bucket = aws_s3_bucket.lab_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket_encryption" {
  bucket = aws_s3_bucket.lab_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
