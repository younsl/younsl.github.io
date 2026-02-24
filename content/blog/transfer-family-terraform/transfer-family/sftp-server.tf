locals {
  username = "alice"
}

#---------------------------------------------
# SFTP Server
#---------------------------------------------
resource "aws_transfer_server" "service_managed_sftp" {
  protocols              = ["SFTP"]
  identity_provider_type = "SERVICE_MANAGED"
  endpoint_type          = "PUBLIC"
  logging_role           = aws_iam_role.sftp_logging.arn

  domain = "S3"
}

# `aws_transfer_tag` resource only supports aws provider v4.35.0 and higher.
resource "aws_transfer_tag" "zone_id" {
  resource_arn = aws_transfer_server.service_managed_sftp.arn
  key          = "aws:transfer:route53HostedZoneId"
  value        = "/hostedzone/${aws_route53_zone.sftp_rocket_dev.zone_id}"
}

# `aws_transfer_tag` resource only supports aws provider v4.35.0 and higher.
resource "aws_transfer_tag" "hostname" {
  resource_arn = aws_transfer_server.service_managed_sftp.arn
  key          = "aws:transfer:customHostname"
  value        = var.sftp_domain
}

#---------------------------------------------
# SFTP User
#---------------------------------------------
resource "aws_transfer_user" "test_user" {
  server_id      = aws_transfer_server.service_managed_sftp.id
  user_name      = local.username
  role           = aws_iam_role.sftp_user.arn
  home_directory = "/${aws_s3_bucket.sftp_sample.bucket}/${local.username}/"
}

#---------------------------------------------
# S3 Bucket for Transfer Server
#---------------------------------------------
resource "aws_s3_bucket" "sftp_sample" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "sftp_sample" {
  bucket = aws_s3_bucket.sftp_sample.id
  acl    = "private"
}