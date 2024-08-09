variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "AWS Region"
}

variable "bucket_name" {
  type        = string
  default     = "rocket-x82q-sftp-bucket"
  description = "S3 bucket name"
}
