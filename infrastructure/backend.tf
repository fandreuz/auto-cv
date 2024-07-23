variable "lambda_package_zip" {
  type    = string
  default = "target.zip"
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

  filename = "${path.module}/../cv-rendering-lambda/${lambda_package_zip}"
}
