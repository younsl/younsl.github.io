#---------------------------------------------
# IAM Role
#---------------------------------------------
resource "aws_iam_role" "sftp_user" {
  name               = "sftp-user"
  description        = "Access S3 bucket from tranfer SFTP"
  assume_role_policy = data.aws_iam_policy_document.sftp_user.json
}

#---------------------------------------------
# IAM Role trust relationship
#---------------------------------------------
data "aws_iam_policy_document" "sftp_user" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sftp_user" {
  role       = aws_iam_role.sftp_user.name
  policy_arn = aws_iam_policy.sftp_user_s3_access.arn
}

#---------------------------------------------
# IAM Policy
#---------------------------------------------
resource "aws_iam_policy" "sftp_user_s3_access" {
  name        = "sftp-user-s3-access"
  policy      = data.aws_iam_policy_document.sftp_user_s3_access.json
}

data "aws_iam_policy_document" "sftp_user_s3_access" {
  version = "2012-10-17"
  statement {
    sid    = "AllowListingOfUserFolder"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.sftp_sample.id}"]
  }
  statement {
    sid    = "HomeDirObjectAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.sftp_sample.id}/*"]
  }
}