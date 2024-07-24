resource "aws_iam_policy" "queue_writer_policy" {
  name_prefix = "auto-cv-work-queue-writer"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
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
        "Resource": "${aws_sqs_queue.work_queue.arn}"
      },
      {
        "Effect": "Allow",
        "Action": "sqs:ListQueues",
        "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "api" {
  role       = aws_iam_role.queue_writer_role.name
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
