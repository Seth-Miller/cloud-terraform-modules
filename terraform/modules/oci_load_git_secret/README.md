# Git Credential Secret
This Terraform module creates an OCI vault, encryption key, and secret containing a Git username and password and returns the OCID of the secret.
Use the [oci_setup](../oci_setup) module to configure an instance to use the secret.

## Description
Create a module resource in your Terraform configuration, replacing the variables with your own.
```terraform
module "oci_load_git_secret" {
  source = "<your_modules_directory>/oci_load_git_secret"
  project_name = var.project_name
  region       = var.region
  compartment  = var.root_compartment_ocid
  git_secret   = var.git_secret
}
```
The `project_name` variable is used for naming resources and creating resource tags.
The `region` variable is used to configure the Terraform resources and provider.
The `compartment` variable is used to configure the Terraform resources.
The `git_secret` variable should contain a Git username and password in json format:
```json
{
  username = <your_username>
  password = <your_password>
}
```
The `secret_id` return variable contains the OCID of the secret.

## Tests
[oci_load_git_secret_test](../../tests/oci_load_git_secret_test)
