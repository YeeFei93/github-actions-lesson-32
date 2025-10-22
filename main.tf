provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "sctp-ce11-tfstate"
    key    = "yeefei-s3-tf-ci.tfstate" #Change this
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = split("/", data.aws_caller_identity.current.arn)[1] #if your name contains any invalid characters like ".", hardcode this name_prefix value = <YOUR NAME>
  account_id  = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "s3_tf" {
  bucket = "${local.name_prefix}-s3-tf-bkt-${local.account_id}"
}

# Enable versioning
resource "aws_s3_bucket_versioning" "s3_tf_versioning" {
  bucket = aws_s3_bucket.s3_tf.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption with AES256 (simpler than KMS)
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_tf_encryption" {
  bucket = aws_s3_bucket.s3_tf.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "s3_tf_public_access_block" {
  bucket                  = aws_s3_bucket.s3_tf.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Minimal lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "s3_tf_lifecycle" {
  bucket = aws_s3_bucket.s3_tf.id
  rule {
    id     = "rule-1"
    status = "Enabled"
    filter {}
  }
}

# Enable access logging to self
resource "aws_s3_bucket_logging" "s3_tf_logging" {
  bucket        = aws_s3_bucket.s3_tf.id
  target_bucket = aws_s3_bucket.s3_tf.id
  target_prefix = "logs/"
}
