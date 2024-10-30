locals {
  envs = { for tuple in regexall("(.*)=(.*)", file(".env")) : tuple[0] => sensitive(tuple[1]) }
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  profile    = "default"
  access_key = local.envs["AWS_ACCESS_KEY_ID"]
  secret_key = local.envs["AWS_SECRET_ACCESS_KEY"]
  token      = local.envs["AWS_SESSION_TOKEN"]
}

resource "aws_s3_bucket" "frontend-bucket" {
  bucket = "terraform-getting-started-guide-frontend-bucket"
}

resource "aws_s3_bucket_public_access_block" "terraform-getting-started-guide-frontend-bucket" {
  bucket = aws_s3_bucket.frontend-bucket.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.frontend-bucket.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.frontend-bucket.arn,
      "${aws_s3_bucket.frontend-bucket.arn}/*"
    ]
  }
}