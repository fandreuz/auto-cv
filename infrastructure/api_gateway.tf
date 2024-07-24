resource "aws_api_gateway_rest_api" "gateway" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  path_part   = "api/v1/cv"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gateway_lambda_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.rendering_lambda.invoke_arn}"
}

resource "aws_api_gateway_deployment" "gateway" {
  depends_on = ["aws_api_gateway_integration.gateway_lambda_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  stage_name  = "test"
}

output "lambda_url" {
  value = "${aws_api_gateway_deployment.gateway.invoke_url}/${aws_api_gateway_resource.proxy.path_part}"
}
