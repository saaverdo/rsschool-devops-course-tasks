output "backup_bucket_name" {
  value       = aws_s3_bucket.backup.bucket
  description = "Backup bucket name"
}

output "k3s_master_instance_external_ip" {
  value       = aws_instance.k3s_master.public_ip
  description = "EC2 instance public ip"
}

output "k3s_master_instance_internal_ip" {
  value       = aws_instance.k3s_master.private_ip
  description = "EC2 instance private ip"
}

output "k3s_worker_instance_internal_ip" {
  value       = aws_instance.k3s_worker.private_ip
  description = "EC2 instance private ip"
}

output "bastion_instance_external_ip" {
  value       = aws_instance.bastion.public_ip
  description = "EC2 instance public ip"
}

output "bastion_instance_internal_ip" {
  value       = aws_instance.bastion.private_ip
  description = "EC2 instance private ip"
}

# output "db_instance_internal_ip" {
#   value       = aws_instance.db.private_ip
#   description = "EC2 instance private ip"
# }

output "s3_ro_role_arn" {
  value = aws_iam_role.s3_ro_role.arn
}

# output "sg_dev_id" {
#   value       = aws_security_group.sg_dev.id
#   description = "Security Group id"
# }

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC id"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "Public subnets ids"
}

output "private_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "Private subnets ids"
}
