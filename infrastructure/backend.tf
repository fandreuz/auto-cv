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

resource "aws_lambda_layer_version" "lambda_dependencies_pkg" {
  layer_name = "lambda_dependencies_pkg_layer"
  s3_bucket  = "cv-rendering-pkg-bucket20240723210849196900000001"
  s3_key     = "cv_rendering_dependencies.zip"

  compatible_runtimes = ["python3.11"]
}

resource "aws_lambda_layer_version" "lambda_code_pkg" {
  layer_name = "lambda_code_pkg_layer"
  s3_bucket  = "cv-rendering-pkg-bucket20240723210849196900000001"
  s3_key     = "cv_rendering_dependencies.zip"

  compatible_runtimes = ["python3.11"]
}

resource "aws_lambda_function" "test_lambda" {
  function_name = "cv-rendering"
  description   = "Render CV"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.11"

  role        = aws_iam_role.iam_cv_rendering_lambda.arn
  memory_size = 128
  timeout     = 300

  layers = [
    aws_lambda_layer_version.lambda_dependencies_pkg.arn,
    aws_lambda_layer_version.lambda_code_pkg.arn
  ]
}
