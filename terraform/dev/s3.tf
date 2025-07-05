locals {
  bootstrap_files = ["deploy_app.sh", "deploy_db.sh", "myapp.service", "deploy_kubectl.sh"]
}

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


resource "aws_s3_bucket_object" "bootstrap" {
  for_each = toset(local.bootstrap_files)
  bucket   = aws_s3_bucket.backup.id
  key      = "bootstrap/${each.value}"
  source   = "../files/bootstrap/${each.value}"
}