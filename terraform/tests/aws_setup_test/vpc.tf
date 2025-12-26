resource "aws_vpc" "vpc1" {
  cidr_block                           = var.cidr_block
  region                               = var.region
  assign_generated_ipv6_cidr_block     = "true"
  enable_dns_hostnames                 = "true"
  enable_dns_support                   = "true"
  enable_network_address_usage_metrics = "false"
  instance_tenancy                     = "default"

  tags = {
    Name    = "${var.project_name}_vpc"
    Project = var.project_name
  }

}
