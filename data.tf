data "aws_secretsmanager_secret" "by-name" {
  name = var.secret_name
}
data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = data.aws_secretsmanager_secret.by-name.id
}