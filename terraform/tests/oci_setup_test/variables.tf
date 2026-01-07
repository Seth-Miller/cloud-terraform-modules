variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "parent_compartment_ocid" {
  type = string
}

variable "vcn_cidr_blocks" {
  type = list(any)
}

variable "public_cidr_blocks" {
  type = list(any)
}

variable "private_cidr_blocks" {
  type = list(any)
}

variable "availability_domain" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "vm_shape" {
  type = string
}

variable "vm_image" {
  type = string
}

variable "vault_name" {
  type = string
}

variable "secret_name" {
  type = string
}