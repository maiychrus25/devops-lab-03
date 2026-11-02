mock_provider "aws" {}
mock_provider "random" {}

variables {
  key_name = "lab3-dtc235180104"
}

run "lab_plan" {
  command = plan

  assert {
    condition     = aws_instance.lab_server.instance_type == "t3.micro"
    error_message = "Use the verified Free Tier eligible instance type."
  }

  assert {
    condition     = aws_instance.lab_server.metadata_options[0].http_tokens == "required"
    error_message = "The instance must require IMDSv2."
  }

  assert {
    condition     = aws_instance.lab_server.root_block_device[0].encrypted
    error_message = "The root EBS volume must be encrypted."
  }

  assert {
    condition     = aws_s3_bucket_versioning.lab_bucket_versioning.versioning_configuration[0].status == "Enabled"
    error_message = "S3 versioning must be enabled."
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.lab_bucket_encryption.rule).apply_server_side_encryption_by_default).sse_algorithm == "AES256"
    error_message = "S3 must use AES256 encryption."
  }
}

run "reject_wrong_region" {
  command = plan

  variables {
    region = "us-east-1"
  }

  expect_failures = [var.region]
}

run "reject_public_ssh" {
  command = plan

  variables {
    ssh_allowed_cidr = "0.0.0.0/0"
  }

  expect_failures = [var.ssh_allowed_cidr]
}
