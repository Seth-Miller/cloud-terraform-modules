# Git Credential Instance Setup
This Terraform module creates a Cloud-Init configuration for an OCI instance that enables Git to use the secret created with the `oci_load_git_secret` module.
Use the [oci_load_git_secret](../oci_load_git_secret) module to create the OCI secret containing the Git credentials.

## Description
Create a module resource in your Terraform configuration, replacing the variable values with your own.
```terraform
module "oci_setup" {
  source = "<your_modules_directory>/oci_setup"
  project_name = var.project_name
  region       = var.region
  secret_ocid  = var.secret_ocid
}
```
The `project_name` variable is used for naming resources and creating resource tags.
The `region` variable is used to configure the Terraform provider.
The `secret_ocid` is the OCID assigned to the OCI secret containing the Git credentials.
The `template_cloudinit_config` return variable contains the base64 encoded Cloud-Init script.

## Tests
[oci_load_setup](../../tests/oci_load_setup)
