variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region namen"
}

variable "github_account" {
  type        = string
  default     = "saaverdo"
  description = "Github account name"
}

variable "github_repo" {
  type        = string
  default     = "rsschool-devops-course-tasks"
  description = "Github repo name"
}

variable "s3_ro_role_name" {
  type        = string
  default     = "s3_ro_role"
  description = "S3 Read-Only role name"
}

variable "backup_bucket_name" {
  type        = string
  default     = "rs-devops-bsv-backup-bucket"
  description = "Bucket for backups name"
}

variable vpc_cidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC supernet CIDR"
}

variable vpc_name {
  type        = string
  default     = "rs-vpc"
  description = "VPC name"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Instance shape"
}

variable "key_name" {
  type        = string
  default     = "web-key"
  description = "Key pair name"
}
