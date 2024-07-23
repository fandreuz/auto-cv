variable "lambda_package_dir" {
  type    = string
  default = "target"
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

  filename = data.archive_file.create_lambda_package_zip.output_path
}

resource "terraform_data" "create_lambda_package" {
  provisioner "local-exec" {
    command = "bash ${path.module}/../cv-rendering-lambda/bootstrap-environment.sh"

    environment = {
      source_code_dir      = "${path.module}$../cv-rendering-lambda"
      source_code_filename = "lambda.py"
      target_dir           = "${path.module}/${var.lambda_package_dir}"
    }
  }
}

data "archive_file" "create_lambda_package_zip" {
  depends_on  = ["terraform_data.create_lambda_package"]
  source_dir  = "${path.module}/${var.lambda_package_dir}"
  output_path = "${path.module}/${var.lambda_package_dir}.zip"
  type        = "zip"
}
