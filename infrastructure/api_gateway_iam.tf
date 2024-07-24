resource "aws_iam_role" "gateway_role" {
  name_prefix = "auto-cv-queue-writer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          type        = "Service"
          Identifiers = ["apigateway.amazonaws.com"]
        }
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        "Sid" : ""
      },
    ]
  })
}
