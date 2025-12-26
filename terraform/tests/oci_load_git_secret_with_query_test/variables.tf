locals {
  git_secret = {
    username = var.git_username
    password = var.git_password
  }
}


variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "root_compartment_ocid" {
  type = string
}

variable "vault_compartment_name" {
  type = string
}

variable "git_username" {
  type      = string
  sensitive = true
}

variable "git_password" {
  type      = string
  sensitive = true
}
