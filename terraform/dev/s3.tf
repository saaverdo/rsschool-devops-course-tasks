resource "aws_s3_bucket" "backup" {
  bucket = var.backup_bucket_name
  tags = {
    Name = var.backup_bucket_name
  }
}

resource "aws_s3_bucket_versioning" "versioning_backend" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}
