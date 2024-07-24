data "aws_iam_policy_document" "gateway_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "gateway_role" {
  name_prefix        = "auto-cv-queue-writer-role"
  assume_role_policy = data.aws_iam_policy_document.gateway_role.json
}
