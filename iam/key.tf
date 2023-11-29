

resource "aws_iam_user" "example_user" {
  name = "adx-s3-ro-user"
}

resource "aws_iam_policy" "s3_adx_readonly_policy" {
  name        = "s3_adx_readonly_policy"
  description = "Policy for S3 read-only access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:GetObject",
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_user_policy_attachment" "attach_s3_readonly_policy" {
  user       = aws_iam_user.example_user.name
  policy_arn = aws_iam_policy.s3_adx_readonly_policy.arn
}

resource "aws_iam_access_key" "example_access_key" {
  user = aws_iam_user.example_user.name
}

output "iam_id" {
  value = aws_iam_access_key.example_access_key.id
}

output "iam_key" {
  value = aws_iam_access_key.example_access_key.secret
}
