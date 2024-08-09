# ==========================================
# Hosted zone
# ==========================================
resource "aws_route53_zone" "sftp_rocket_dev" {
  name = "rocket.dev"
}

# ==========================================
# Record
# ==========================================
resource "aws_route53_record" "sftp_rocket_dev" {
  zone_id = aws_route53_zone.sftp_rocket_dev.zone_id
  name    = "sftp.rocket.dev"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_transfer_server.service_managed_sftp.endpoint]
}
