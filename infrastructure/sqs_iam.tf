data "aws_iam_policy_document" "sqs_writer_policy" {
  statement {
    resources = [aws_sqs_queue.work_queue.arn]
    actions = [
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
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "sqs_writer_policy" {
  policy = data.aws_iam_policy_document.sqs_writer_policy.json
}

resource "aws_iam_role_policy_attachment" "gateway_sqs_writer_attachment" {
  role       = aws_iam_role.gateway_role.name
  policy_arn = aws_iam_policy.sqs_writer_policy.arn
}

data "aws_iam_policy_document" "sqs_reader_policy" {
  statement {
    resources = [aws_sqs_queue.work_queue.arn]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "sqs_reader_policy" {
  policy = data.aws_iam_policy_document.sqs_reader_policy.json
}


resource "aws_iam_role_policy_attachment" "lambda_execution_sqs_reader_attachment" {
  role       = aws_iam_role.render_lambda_execution_role.name
  policy_arn = aws_iam_policy.sqs_reader_policy.arn
}
