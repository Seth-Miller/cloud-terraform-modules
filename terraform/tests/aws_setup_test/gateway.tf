resource "aws_internet_gateway" "gateway1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name    = "${var.project_name}_gateway"
    Project = var.project_name
  }

}
