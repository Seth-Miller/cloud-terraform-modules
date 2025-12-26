resource "aws_secretsmanager_secret" "secret" {
  name                    = "${var.project_name}_git-secret"
  description             = "Git credentials"
  recovery_window_in_days = 0

  tags = {
    Name    = "${var.project_name}_git-secret"
    Project = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(var.git_secret)
}

output "secret_arn" {
  value = aws_secretsmanager_secret_version.secret.arn
}