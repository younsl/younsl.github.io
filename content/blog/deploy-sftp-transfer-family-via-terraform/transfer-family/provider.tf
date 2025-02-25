terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    # Null provider will create a custom hostname to sftp server.
    # See sftp-server-hostname.tf for details.
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Description = "Demo AWS Transfer Family via Terraform"
    }
  }
}