variable "s3_bucket_id" {
  type    = string
  default = "cv-rendering-pkg-bucket20240723210849196900000001"
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

resource "aws_lambda_function" "rendering_lambda" {
  function_name = "cv-rendering"
  description   = "Render CV"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.11"

  role    = aws_iam_role.render_lambda_execution_role.arn
  timeout = 15

  filename = data.archive_file.lambda_code_pkg.output_path
  layers   = [aws_lambda_layer_version.lambda_dependencies_pkg.arn]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rendering_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
}
