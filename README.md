# Public Cloud Terraform Modules
Create cloud service configurations that perform a specific function.

## Description
Each Terraform module provisions and configures multiple cloud services within a provider to serve a specific function.

## Getting Started
See the [tests](terraform/tests) directory for examples.

### Installation
Step-by-step instructions on how to download your project and get the development environment running.
1.  Copy the module to your modules directory.
    ```bash
    cp terraform/modules/aws_load_git_secret <your_modules_directory>
    ```
2.  Create a module resource in your Terraform configuration, replacing the variables with your own.
    ```bash
    module "aws_load_git_secret" {
      source = "<your_modules_directory>"
      project_name = var.project_name
      region       = var.region
      git_secret   = local.git_secret
    }
    ```

### Tests
Each module includes a test, which can be found in the [tests](terraform/tests) directory. Jenkins pipelines for tests can be found in the [jenkins](jenkins) directory.
