resource "aws_s3_bucket" "backend" {
  bucket = "rs-devops-tf-state-bucket"
  tags = {
    Name    = "TF state bucket"
    Project = "Devops"
  }
}

resource "aws_s3_bucket_versioning" "versioning_backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
#   name = "rs-devops-tf-state-lock"
#   hash_key = "LockID"
#   read_capacity = 1
#   write_capacity = 1

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

output "state_bucket" {
  value = aws_s3_bucket.backend.bucket
}
