locals {
  username = "alice"
}

resource "aws_transfer_user" "test_user" {
  server_id      = aws_transfer_server.service_managed_sftp.id
  user_name      = local.username
  role           = aws_iam_role.sftp_user.arn
  home_directory = "/${aws_s3_bucket.sftp_sample.bucket}/${local.username}/"
}
