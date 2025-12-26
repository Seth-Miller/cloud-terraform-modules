module "aws_setup" {
  source = "../../modules/aws_setup"

  project_name = var.project_name
  region       = var.region
  secret_name  = var.secret_name
}


resource "aws_instance" "vm" {
  ami                         = var.vm_ami
  availability_zone           = var.availability_zone
  enable_primary_ipv6         = "true"
  associate_public_ip_address = "true"
  iam_instance_profile        = aws_iam_instance_profile.profile.name

  cpu_options {
    core_count       = "1"
    threads_per_core = "2"
  }

  hibernation                          = "false"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = var.vm_instance_type
  ipv6_address_count                   = "1"
  key_name                             = "${var.project_name}_ssh-key"

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = "2"
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }

  monitoring                 = "false"
  placement_partition_number = "0"
  user_data_base64           = module.aws_setup.template_cloudinit_config
  region                     = var.region

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    iops                  = "3000"
    throughput            = "125"
    volume_size           = "8"
    volume_type           = "gp3"
  }

  source_dest_check = "true"
  subnet_id         = aws_subnet.subnet1.id

  tenancy                = "default"
  vpc_security_group_ids = [aws_default_security_group.sg1.id]

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "echo 'instance is ready for use!'"
    ]

    connection {
      host        = aws_instance.vm.public_ip
      user        = "ec2-user"
      private_key = tls_private_key.ssh.private_key_pem
      agent       = false
      timeout     = "5m"
    }
  }

  tags = {
    Name    = "${var.project_name}_instance"
    Project = var.project_name
  }

}

output "public_ip" {
  value = aws_instance.vm.public_ip
}
