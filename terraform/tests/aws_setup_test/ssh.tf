resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.project_name}_ssh-key"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = {
    Name    = "${var.project_name}_ssh-key"
    Project = var.project_name
  }
}

output "private_key_pem" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}
