


resource "oci_core_instance" "vm" {
  availability_domain = var.availability_domain
  compartment_id      = oci_identity_compartment.id.id
  display_name    = "${var.project_name}_instance"

  create_vnic_details {
    display_name    = "${var.project_name}_vnic"
    hostname_label    = "${var.project_name}_instance"
    subnet_id      = oci_core_subnet.lab_public.id
  }

  metadata = {
    "ssh_authorized_keys" = var.ssh_key,
#    "user_data"           = "${data.template_cloudinit_config.config.rendered}"
  }
  shape = var.vm_shape
  shape_config {
    memory_in_gbs = "4"
    ocpus         = "1"
  }
  source_details {
    boot_volume_vpus_per_gb = "10"
    source_id               = var.vm_image
    source_type             = "image"
  }

  tags = {
    Name    = "${var.project_name}_instance"
    Project = var.project_name
  }
}

resource "oci_core_vnic_attachment" "vm" {
  instance_id = oci_core_instance.vm.id
  create_vnic_details {
    subnet_id = oci_core_subnet.lab_private.id
  }
}

output "public-ip" {
  value = oci_core_instance.vm.public_ip
}
