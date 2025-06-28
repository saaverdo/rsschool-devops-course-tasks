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

variable "GHA_role_name" {
  type        = string
  default     = "GithubActionsRole"
  description = "IAM role for Github Actions"
}
