 
module "iam" {
  source = "../iam"
}
 
resource "random_integer" "myrandom" {
  min =001
  max = 100
}  

resource "aws_secretsmanager_secret" "example_secret" {
  name = "${var.prefix}${var.aws_secretsmanager_secret_name}${var.postfix}${var.environment}${(random_integer.myrandom.id)}"
  description = "Secret Manager resource in aws"
}
# module "iam" {
#   source = "../iam"
#   # other module configuration options
# }
resource "aws_secretsmanager_secret_version" "example_secret_version" {
  secret_id     = aws_secretsmanager_secret.example_secret.id
  secret_string = jsonencode({
    iam_id = module.iam.iam_id
    iam_key = module.iam.iam_key
    app_id     = var.aws_secretsmanager_secret_version_secret_string["app_id"]
    app_key    = var.aws_secretsmanager_secret_version_secret_string["app_key"]
  })
  
  #Specify the retention period in days (e.g., default 30 days)
  #version_stages = ["AWSCURRENT"]
  #version_id     = "AWSCURRENT"   
}
output "secret_arn" {
  value = aws_secretsmanager_secret.example_secret.arn
}