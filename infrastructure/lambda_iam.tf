data "aws_iam_policy_document" "render_lambda_execution_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "render_lambda_execution_role" {
  name_prefix        = "render_lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.render_lambda_execution_role.json
}
