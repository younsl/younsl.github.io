#---------------------------------------------
# Hosted zone
#---------------------------------------------
resource "aws_route53_zone" "sftp_rocket_dev" {
  # Route53 zone name is without the subdomain.
  # For example, if the subdomain is set to "sftp.rocket.dev",
  # Route53 zone name is "rocket.dev".
  name = join(".", slice(split(".", var.sftp_domain), 1, length(split(".", var.sftp_domain))))
}

#---------------------------------------------
# Record (CNAME)
#---------------------------------------------
resource "aws_route53_record" "sftp_rocket_dev" {
  zone_id = aws_route53_zone.sftp_rocket_dev.zone_id
  name    = var.sftp_domain
  type    = "CNAME"
  ttl     = "300"
  records = [aws_transfer_server.service_managed_sftp.endpoint]
}