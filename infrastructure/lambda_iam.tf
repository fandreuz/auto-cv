resource "aws_iam_role" "render_lambda_execution_role" {
  name_prefix = "render_lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Resource = "*"
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow"
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

    Statement = [{
      Sid       = "AllowInvokingLambdas"
      Effect    = "Allow"
      Resources = ["arn:aws:lambda:ap-southeast-1:*:function:*"]
      Actions   = ["lambda:InvokeFunction"]
    }]

    Statement = [{
      Sid       = "AllowCreatingLogGroups"
      Effect    = "Allow"
      Resources = ["arn:aws:logs:ap-southeast-1:*:*"]
      Actions   = ["logs:CreateLogGroup"]
    }]

    Statement = [{
      Sid       = "AllowWritingLogs"
      Effect    = "Allow"
      Resources = ["arn:aws:logs:ap-southeast-1:*:log-group:/aws/lambda/*:*"]
      Actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
    }]
  })
}
