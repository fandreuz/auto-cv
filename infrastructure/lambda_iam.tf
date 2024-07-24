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

data "aws_iam_policy_document" "render_lambda_logs_policy" {
  statement {
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "render_lambda_logs_policy" {
  policy = data.aws_iam_policy_document.render_lambda_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "render_lambda_logs_policy_attachment" {
  role       = aws_iam_role.render_lambda_execution_role.name
  policy_arn = aws_iam_policy.render_lambda_logs_policy.arn
}
