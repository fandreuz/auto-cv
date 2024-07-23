variable "s3_bucket_id" {
  type    = string
  default = "cv-rendering-pkg-bucket20240723210849196900000001"
}

variable "s3_bucket_key" {
  type    = string
  default = "cv_rendering_pkg.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_cv_rendering_lambda" {
  name               = "iam_cv_rendering_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
