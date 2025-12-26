resource "aws_subnet" "subnet1" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = var.cidr_block
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.vpc1.ipv6_cidr_block, 8, 0)
  enable_dns64                                   = "false"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_public_ip_on_launch                        = "false"
  private_dns_hostname_type_on_launch            = "ip-name"
  availability_zone                              = var.availability_zone

  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name    = "${var.project_name}_subnet"
    Project = var.project_name
  }

}
