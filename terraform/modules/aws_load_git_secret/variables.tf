variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "git_secret" {
  type      = map(string)
  sensitive = true
}
