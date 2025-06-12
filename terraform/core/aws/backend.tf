terraform {
  backend "s3" {
    encrypt = true
    bucket  = "rs-devops-tf-state-bucket"
    # dynamodb_table = "rs-devops-tf-state-lock" # deprecated
    use_lockfile = true
    key          = "core/terraform.tfstate"
    region       = "eu-north-1"
  }
}