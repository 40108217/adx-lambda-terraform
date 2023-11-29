variable "region" {
  description = "Region name in which the vpc need to be created"
  type = string
  default = "us-east-1"
}
variable "aws_secretsmanager_secret_name" {
  type        = string
  description = "secret manager name."
  default     = "adx-secret-Manager"
}

variable "aws_secretsmanager_secret_version_secret_string" {
  type        = map(string)
  description = "Map containing secret values for AWS Secrets Manager."

  default = {
    #iam_id  = "secret_iam_id"
    #iam_key = "secret_iam_key"
    app_id  = "secret_app_id"
    app_key = "secret_app_key"
  }
}


variable "environment" {
  type        = string
  default     = "prod-"
}
variable "prefix" {
  type        = string
  default     = "aws-"
}

variable "postfix" {
  type        = string
  default     = "-usw-ccoe-"
}
