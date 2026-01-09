# Git Credential Secret
This Terraform module creates an AWS secret containing a Git username and password and returns the ARN of the secret.
Use the [aws_setup](../aws_setup) module to configure an instance to use the secret.

## Description
Create a module resource in your Terraform configuration, replacing the variables with your own.
```bash
module "aws_load_git_secret" {
  source = "<your_modules_directory>/aws_load_git_secret"
  project_name = var.project_name
  region       = var.region
  git_secret   = local.git_secret
}
```
The `project_name` variable is used for naming resources and creating resource tags.
The `region` variable is used to configure the Terraform resources and provider.
The `git_secret` variable should contain a Git username and password in json format:
```
{
  username = <your_username>
  password = <your_password>
}
```
The `secret_arn` return variable contains the ARN of the secret.

## Tests
[aws_load_git_secret_test](../../tests/aws_load_git_secret_test)
