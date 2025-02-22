resource "aws_s3_bucket" "sftp_sample" {
  # Note:
  # Bucket name must be unique globally.
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "sftp_sample" {
  bucket = aws_s3_bucket.sftp_sample.id
  acl    = "private"
}
