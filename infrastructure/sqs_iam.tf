resource "aws_iam_policy" "sqs_writer_policy" {
  policy = jsonencode({
    "Version" : "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:SendMessageBatch",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:CreateQueue",
          "sqs:ListQueueTags",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:SetQueueAttributes"
        ],
        "Resource" : "${aws_sqs_queue.work_queue.arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : "sqs:ListQueues",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api" {
  role       = aws_iam_role.gateway_role.name
  policy_arn = aws_iam_policy.queue_writer_policy.arn
}

resource "aws_iam_role_policy_attachment" "example_lambda" {
  role       = aws_iam_role.render_lambda_execution_role.name
  policy_arn = aws_iam_policy.sqs_reader_policy.arn
}

resource "aws_iam_policy" "sqs_reader_policy" {
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
