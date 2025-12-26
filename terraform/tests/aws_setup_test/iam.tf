data "aws_secretsmanager_secret" "secret" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

resource "aws_iam_role" "role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  max_session_duration = "3600"
  name                 = "${var.project_name}_role"
  path                 = "/"

  tags = {
    Name    = "${var.project_name}_role"
    Project = var.project_name
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.project_name}_policy"
  description = "Allows reading a specific secret from Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = data.aws_secretsmanager_secret_version.secret.arn
    }]
  })

  tags = {
    Name    = "${var.project_name}_policy"
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.project_name}_profile"
  role = aws_iam_role.role.name

  tags = {
    Name    = "${var.project_name}_profile"
    Project = var.project_name
  }
}
