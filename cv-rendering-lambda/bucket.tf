terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "cv_rendering_pkg_bucket" {
  bucket_prefix = "cv-rendering-pkg-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.cv_rendering_pkg_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.cv_rendering_pkg_bucket.id
  key    = "cv_rendering_pkg.zip"
  source = "${path.module}/target.zip"
  etag   = "${path.module}/target.zip"
}
