output "sftp_server_id" {
  value       = aws_transfer_server.service_managed_sftp.id
  description = "The Server ID of AWS Transfer Server"
}

output "sftp_server_endpoint" {
  value       = aws_transfer_server.service_managed_sftp.endpoint
  description = "The endpoint of AWS Transfer Server"
}

output "sftp_username" {
  value       = aws_transfer_user.test_user.user_name
  description = "The name of AWS Transfer User"
}

output "bucket_name" {
  value        = aws_s3_bucket.sftp_sample.bucket
  description  = "The name of S3 Bucket"
}