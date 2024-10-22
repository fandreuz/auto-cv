resource "aws_api_gateway_rest_api" "gateway" {
  name = "AutoCV-GW"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "cv_resource" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "cv"
}

resource "aws_api_gateway_method" "cv_resource" {
  rest_api_id      = aws_api_gateway_rest_api.gateway.id
  resource_id      = aws_api_gateway_resource.cv_resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false

  request_validator_id = aws_api_gateway_request_validator.gateway_validator.id
  request_models = {
    "application/json" = aws_api_gateway_model.gateway_model.name
  }
}

resource "aws_api_gateway_integration" "gateway_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_method.cv_resource.resource_id
  http_method = aws_api_gateway_method.cv_resource.http_method

  integration_http_method = aws_api_gateway_method.cv_resource.http_method
  type                    = "AWS"
  passthrough_behavior    = "NEVER"
  credentials             = aws_iam_role.gateway_role.arn
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${aws_sqs_queue.work_queue.name}"
}

resource "aws_api_gateway_deployment" "gateway" {
  depends_on = [aws_api_gateway_integration.gateway_lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.gateway.id
  stage_name  = "test"
}

output "auto_cv_url" {
  value = "${aws_api_gateway_deployment.gateway.invoke_url}/${aws_api_gateway_resource.api_resource.path_part}/${aws_api_gateway_resource.cv_resource.path_part}"
}

resource "aws_api_gateway_model" "gateway_model" {
  rest_api_id  = aws_api_gateway_rest_api.gateway.id
  name         = "PayloadValidator"
  description  = "validate the json body"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "required": [ "identifier", "cv_yaml"],
  "properties": {
    "identifier": { "type": "string" },
    "cv_yaml": { "type": "string" }
  }
}
EOF
}

resource "aws_api_gateway_request_validator" "gateway_validator" {
  rest_api_id           = aws_api_gateway_rest_api.gateway.id
  name                  = "payload-validator"
  validate_request_body = true
}

resource "aws_api_gateway_integration_response" "gateway_integration_response" {
  rest_api_id       = aws_api_gateway_rest_api.gateway.id
  resource_id       = aws_api_gateway_resource.cv_resource.id
  http_method       = aws_api_gateway_method.cv_resource.http_method
  status_code       = "200"
  selection_pattern = "^2[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"Task scheduled\"}"
  }

  depends_on = [aws_api_gateway_integration.gateway_lambda_integration]
}

resource "aws_api_gateway_method_response" "gateway_method_response" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.cv_resource.id
  http_method = aws_api_gateway_method.cv_resource.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}