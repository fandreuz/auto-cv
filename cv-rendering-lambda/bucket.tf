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

variable "dependencies_pkg_filename" {
  type    = string
  default = "cv_rendering_dependencies.zip"
}

variable "lambda_code_pkg_filename" {
  type    = string
  default = "cv_rendering_lambda.zip"
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

resource "aws_s3_object" "dependencies_pkg" {
  bucket      = aws_s3_bucket.cv_rendering_pkg_bucket.id
  key         = var.dependencies_pkg_filename
  source      = "${path.module}/${var.dependencies_pkg_filename}"
  etag        = filemd5("${path.module}/${var.dependencies_pkg_filename}")
  source_hash = filemd5("${path.module}/${var.dependencies_pkg_filename}")
}

resource "aws_s3_object" "lambda_code_pkg" {
  bucket      = aws_s3_bucket.cv_rendering_pkg_bucket.id
  key         = "${var.lambda_code_pkg_filename}"
  source      = "${path.module}/${var.lambda_code_pkg_filename}"
  etag        = filemd5("${path.module}/${var.lambda_code_pkg_filename}")
  source_hash = filemd5("${path.module}/${var.lambda_code_pkg_filename}")
}

output "s3_bucket_id" {
  value = aws_s3_bucket.cv_rendering_pkg_bucket.id
}

output "s3_dependencies_bucket_key" {
  value = aws_s3_object.dependencies_pkg.key
}

output "s3_lambda_bucket_key" {
  value = aws_s3_object.lambda_code_pkg.key
}
