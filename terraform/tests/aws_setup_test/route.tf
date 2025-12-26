resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway1.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gateway1.id
  }

  tags = {
    Name    = "${var.project_name}_route"
    Project = var.project_name
  }

}

resource "aws_route_table_association" "routeass1" {
  route_table_id = aws_route_table.route1.id
  subnet_id      = aws_subnet.subnet1.id
}
