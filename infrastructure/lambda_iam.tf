resource "aws_iam_role" "render_lambda_execution_role" {
  name_prefix = "render_lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principals = {
          type        = "Service"
          Identifiers = ["lambda.amazonaws.com"]
        }
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_lambda" {
  role       = aws_iam_role.render_lambda_execution_role.name
  policy_arn = aws_iam_policy.render_lambda_execution_policy.arn
}

resource "aws_iam_policy" "render_lambda_execution_policy" {
  policy = jsonencode({
    Statement = [{
      Sid       = "AllowSQSPermissions"
      Effect    = "Allow"
      Resources = ["arn:aws:sqs:*"]
      Actions = [
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage",
      ] }
    ]
  })
}
