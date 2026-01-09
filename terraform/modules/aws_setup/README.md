# Git Credential Instance Setup
This Terraform module creates a Cloud-Init configuration for an AWS instance that enables Git to use the secret created with the `aws_load_git_secret` module.
Use the [aws_load_git_secret](../aws_load_git_secret) module to create the AWS secret containing the Git credentials.

## Description
Create a module resource in your Terraform configuration, replacing the variables with your own.
```terraform
module "aws_setup" {
  source = "<your_modules_directory>"
  project_name = var.project_name
  region       = var.region
  secret_name  = var.secret_name
}
```
The `project_name` variable is used for naming resources and creating resource tags.
The `region` variable is used to configure the Terraform provider and the AWS client that accesses the secret.
The `secret_name` is the name assigned to the AWS secret containing the Git credentials.
The `template_cloudinit_config` return variable contains the base64 encoded Cloud-Init script.

## Tests
[aws_load_setup](../../tests/aws_load_setup)
