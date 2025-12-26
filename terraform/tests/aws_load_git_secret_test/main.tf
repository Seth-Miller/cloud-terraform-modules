module "aws_load_git_secret" {
  source = "../../modules/aws_load_git_secret"

  project_name = var.project_name
  region       = var.region
  git_secret   = local.git_secret
}
