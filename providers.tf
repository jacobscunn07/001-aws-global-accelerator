terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  allowed_account_ids = [var.aws_account_id]
  region              = "us-east-1"
  alias               = "us-east-1"
}

provider "aws" {
  allowed_account_ids = [var.aws_account_id]
  region              = "ap-southeast-2"
  alias               = "ap-southeast-2"
}
