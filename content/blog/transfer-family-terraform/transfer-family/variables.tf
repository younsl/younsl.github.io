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

variable "sftp_domain" {
  type        = string
  default     = "sftp.rocket.dev"
  description = "SFTP server custom hostname"
}