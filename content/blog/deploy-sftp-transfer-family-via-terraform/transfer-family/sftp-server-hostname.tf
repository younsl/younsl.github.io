resource "null_resource" "service_managed_sftp_custom_hostname" {
  depends_on = [aws_transfer_server.service_managed_sftp]

  # 테라폼이 local-exec 프로비저너를 사용해서
  # 로컬에서 직접 AWS CLI 명령어를 실행한다.
  # 생성한 transfer family 서버 리소스에
  # `aws:transfer:customHostname` 태그를 붙인다.
  provisioner "local-exec" {
    command = <<EOF
aws transfer tag-resource \
  --arn '${aws_transfer_server.service_managed_sftp.arn}' \
  --tags 'Key=aws:transfer:customHostname,Value=sftp.rocket.dev' \
  --region 'ap-northeast-2'
EOF
  }
}