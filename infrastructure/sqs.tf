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
