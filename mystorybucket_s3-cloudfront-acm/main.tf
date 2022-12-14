module "s3-cloudfront-website" {
  source  = "riboseinc/s3-cloudfront-website/aws"
  version = "1.0.0"
  fqdn = "www.mystorybucket.com" # insert the 2 required variables here
  ssl_certificate_arn = var.ssl_certificate_arn
}

# Kudos goes to igor-kupczynski for the following code. See: https://github.com/igor-kupczynski/terraform_static_aws_website 
#Lambda defined here invalidates CloudFront cache in case the cached object in S3 is changed
resource "aws_iam_role" "invalidate_cloud_front_role" {
  count = var.ssl_certificate_arn != "" ? 1 : 0
  name  = "invalidate_cloud_front"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "invalidate_cloud_front_policy" {
  count       = var.ssl_certificate_arn != "" ? 1 : 0
  name        = "invalidate_cloud_front_policy"
  description = "Allow to create CloudFront invalidations"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:CreateInvalidation"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "invalidate_cloud_front_attachment" {
  count      = var.ssl_certificate_arn != "" ? 1 : 0
  role       = aws_iam_role.invalidate_cloud_front_role[count.index].name
  policy_arn = aws_iam_policy.invalidate_cloud_front_policy[count.index].arn
}

data "archive_file" "invalidate_cloud_front_lambda_zip" {
  count       = var.ssl_certificate_arn != "" ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/invalidate_cloud_front.py"
  output_path = "${path.module}/invalidate_cloud_front_lambda.zip"
}

resource "aws_lambda_function" "invalidate_cloud_front_lambda" {
  count            = var.ssl_certificate_arn != "" ? 1 : 0
  filename         = data.archive_file.invalidate_cloud_front_lambda_zip[count.index].output_path
  function_name    = "inalidate_cloud_front_on_s3_change"
  role             = aws_iam_role.invalidate_cloud_front_role[count.index].arn
  handler          = "invalidate_cloud_front.handle_s3_change"
  source_code_hash = data.archive_file.invalidate_cloud_front_lambda_zip[count.index].output_base64sha256
  runtime          = "python3.7"

  environment {
    variables = {
      CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.cdn[0].id
    }
  }
}

resource "aws_lambda_permission" "allow_s3_event_notifications" {
  count         = var.ssl_certificate_arn != "" ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invalidate_cloud_front_lambda[count.index].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.storage_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = (var.ssl_certificate_arn != "" ? 1 : 0) * (var.invalidate_cloud_front_on_s3_update ? 1 : 0)
  bucket = aws_s3_bucket.storage_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.invalidate_cloud_front_lambda[count.index].arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

