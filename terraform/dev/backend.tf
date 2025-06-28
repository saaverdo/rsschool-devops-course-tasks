terraform {
  backend "s3" {
    encrypt      = true
    bucket       = "rs-devops-tf-state-bucket"
    use_lockfile = true
    key          = "dev/terraform.tfstate"
    region       = "eu-north-1"
  }
}