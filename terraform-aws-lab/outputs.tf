output "ec2_instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.lab_server.id
}

output "ec2_public_ip" {
  description = "EC2 public IPv4 address"
  value       = aws_instance.lab_server.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS name"
  value       = aws_instance.lab_server.public_dns
}

output "ec2_private_ip" {
  description = "EC2 private IPv4 address"
  value       = aws_instance.lab_server.private_ip
}

output "s3_bucket_name" {
  description = "Created S3 bucket name"
  value       = aws_s3_bucket.lab_bucket.bucket
}

output "s3_bucket_arn" {
  description = "Created S3 bucket ARN"
  value       = aws_s3_bucket.lab_bucket.arn
}

output "ssh_connect_command" {
  description = "SSH command using the private key stored outside the submission"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.lab_server.public_dns}"
}

output "lab_summary" {
  description = "Lab infrastructure summary"
  value = {
    EC2_ID      = aws_instance.lab_server.id
    EC2_IP      = aws_instance.lab_server.public_ip
    S3_Bucket   = aws_s3_bucket.lab_bucket.bucket
    Environment = var.environment
    Region      = var.region
  }
}
