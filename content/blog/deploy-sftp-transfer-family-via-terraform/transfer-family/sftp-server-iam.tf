# ==========================================
# IAM Role
# ==========================================
resource "aws_iam_role" "sftp_logging" {
  name               = "sftp-logging"
  description        = "Write logs from sftp server to CloudWatch"
  assume_role_policy = data.aws_iam_policy_document.sftp_logging.json
}

# ==========================================
# IAM Role trust relationship
# ==========================================
data "aws_iam_policy_document" "sftp_logging" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

# ===============================================
# IAM Policy
# ===============================================
resource "aws_iam_role_policy_attachment" "sftp_logging" {
  role       = aws_iam_role.sftp_logging.name
  policy_arn = aws_iam_policy.sftp_logging.arn
}

resource "aws_iam_policy" "sftp_logging" {
  name   = "sftp-logging"
  policy = data.aws_iam_policy_document.sftp_logging_cloudwatch.json
}

data "aws_iam_policy_document" "sftp_logging_cloudwatch" {
  version = "2012-10-17"
  statement {
    sid       = "AllowFullAccesstoCloudWatchLogs"
    effect    = "Allow"
    actions   = [
      "logs:*"
    ]
    resources = [
      "*"
    ]
  }
}
