resource "aws_default_security_group" "sg1" {
  region = var.region
  vpc_id = aws_vpc.vpc1.id

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = "0"
    protocol         = "-1"
    to_port          = "0"
  }

  ingress {
    from_port        = "22"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    to_port          = "22"
  }

  tags = {
    Name    = "${var.project_name}_sg"
    Project = var.project_name
  }

}
