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
