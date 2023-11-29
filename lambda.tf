

module "secrets" {
  source = "./secrets"
}
# module "secret-s3" {
#   source = "./secrets"
# }
data "archive_file" "lambda-code-archieve" {
  type        = "zip"
  #source_file = "${path.module}/python/hello-python.py"
  #output_path = "${path.module}/python/hello-python.zip"
  source_file = "python/lambda_function.py"
  output_path = "python/lambda_function.zip"
}

resource "aws_lambda_layer_version" "python_layer" {
  layer_name          = "python_azure_layer_example"
  description         = "Python layer example"
  compatible_runtimes = ["python3.8"]
  filename            = "python/python.zip"
  source_code_hash    = filebase64("python/python.zip")
}



resource "aws_lambda_function" "example" {
  function_name = "${var.prefix}${var.lambda_function_name}${var.postfix}"
  handler       = var.lambda_function_handler
  runtime       = var.lambda_function_runtime
  role          = aws_iam_role.lambda_role.arn
  filename      = "python/lambda_function.zip"
  layers        = [aws_lambda_layer_version.python_layer.arn]
  memory_size   = 256
  timeout       = 15

  environment {
    variables = {
      TENENT_ID          = var.TENENT_ID
      CLUSTER_INGEST_URI = var.CLUSTER_INGEST_URI
      DATABASE           = var.DATABASE
      TABLE              = var.TABLE
      MAPPING            = var.MAPPING
      SECRET_ID          = module.secrets.secret_arn
      app_id             = var.app_id
      app_key            = var.app_key
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.prefix}${var.iam}${var.postfix}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-basic-policy1"
  description = "Basic Lambda execution policy"

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
      "Resource": "*"
    },
  {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}/*"
        
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowS3Invocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.source_arn
}

resource "aws_s3_bucket_notification" "example_notification" {
  bucket = var.bucket_name
  lambda_function {
    lambda_function_arn = aws_lambda_function.example.arn
    events              = ["s3:ObjectCreated:*"]
  }
}