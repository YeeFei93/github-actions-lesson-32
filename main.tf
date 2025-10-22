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

#checkov:skip=CKV_AWS_145:KMS encryption not required for this bucket
#checkov:skip=CKV_AWS_18:Access logging not required for this bucket
#checkov:skip=CKV2_AWS_62:Event notifications not required for this bucket
#checkov:skip=CKV2_AWS_6:Public access block not required for this bucket
#checkov:skip=CKV2_AWS_61:Lifecycle configuration not required for this bucket
#checkov:skip=CKV_AWS_21:Versioning not required for this bucket
#checkov:skip=CKV_AWS_144:Cross-region replication not required for this bucket
resource "aws_s3_bucket" "s3_tf" {
  bucket = "${local.name_prefix}-s3-tf-bkt-${local.account_id}"
}