variable "project_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "vm_ami" {
  type = string
}

variable "vm_instance_type" {
  type = string
}

variable "vm_ssh_key" {
  type = string
}

variable "secret_name" {
  type      = string
}
