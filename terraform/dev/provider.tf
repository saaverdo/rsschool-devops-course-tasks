provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "rs-devops"
    }
  }
}
