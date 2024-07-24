variable "s3_bucket_id" {
  type    = string
  default = "cv-rendering-pkg-bucket20240723210849196900000001"
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

data "archive_file" "lambda_code_pkg" {
  type        = "zip"
  source_file = "${path.module}/../cv-rendering-lambda/lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name = "cv-rendering"
  description   = "Render CV"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.11"

  role        = aws_iam_role.iam_cv_rendering_lambda.arn
  memory_size = 128
  timeout     = 300

  filename = data.archive_file.lambda_code_pkg.output_path
}
