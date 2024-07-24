resource "aws_sqs_queue" "work_queue" {
  name_prefix                = "auto-cv-queue"
  visibility_timeout_seconds = 30
  max_message_size           = 102400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.work_queue_dwadletter.arn
    maxReceiveCount     = 2
  })
}

resource "aws_sqs_queue" "work_queue_dwadletter" {
  name = "terraform-example-deadletter-queue"
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.work_queue_dwadletter.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.work_queue.arn]
  })
}

resource "aws_lambda_event_source_mapping" "work_queue_to_lambda" {
  event_source_arn                   = aws_sqs_queue.work_queue.arn
  function_name                      = aws_lambda_function.rendering_lambda.arn
  maximum_batching_window_in_seconds = 10
}

# https://gist.github.com/afloesch/dc7d8865eeb91100648330a46967be25
resource "aws_iam_role" "queue_writer_role" {
  name_prefix = "auto-cv-queue-writer-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

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
