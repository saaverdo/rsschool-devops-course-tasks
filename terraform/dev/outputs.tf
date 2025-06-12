output "backup_bucket_name" {
  value       = aws_s3_bucket.backup.bucket
  description = "Backup bucket name"
}

output "instance_external_ip" {
  value       = aws_instance.web.public_ip
  description = "EC2 instance public ip"
}

output "instance_internal_ip" {
  value       = aws_instance.web.private_ip
  description = "EC2 instance private ip"
}

output "s3_ro_role_arn" {
  value = aws_iam_role.s3_ro_role.arn
}

output "sg_dev_id" {
  value       = aws_security_group.sg_dev.id
  description = "Security Group id"
}