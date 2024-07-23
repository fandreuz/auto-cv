variable "s3_bucket_id" {
  type    = string
  default = "cv-rendering-pkg-bucket20240723210849196900000001"
}

variable "s3_bucket_key" {
  type    = string
  default = "cv_rendering_pkg.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_cv_rendering_lambda" {
  name               = "iam_cv_rendering_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "test_lambda" {
  function_name = "cv-rendering"
  description   = "Render CV"
  handler       = "cv_rendering.lambda.lambda_handler"
  runtime       = "python3.11"

  role        = aws_iam_role.iam_cv_rendering_lambda.arn
  memory_size = 128
  timeout     = 300

  s3_bucket = var.s3_bucket_id
  s3_key    = var.s3_bucket_key
}
