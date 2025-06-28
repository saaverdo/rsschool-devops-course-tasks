variable "account_id" {
  type        = string
  description = "Account ID"
}

variable "github_account" {
  type        = string
  default     = "saaverdo"
  description = "Github account"
}

variable "github_repo" {
  type        = string
  default     = "rsschool-devops-course-tasks"
  description = "Github repo"
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
