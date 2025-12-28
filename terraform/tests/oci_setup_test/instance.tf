module "oci_setup" {
  source = "../../modules/oci_setup"

  project_name = var.project_name
  region       = var.region
  secret_ocid  = data.oci_vault_secrets.secret.secrets[0].id
}


resource "oci_core_instance" "vm" {
  availability_domain = var.availability_domain
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "${var.project_name}_instance"

  create_vnic_details {
    display_name   = "${var.project_name}_vnic"
    hostname_label = "vm"
    subnet_id      = oci_core_subnet.lab_public.id
  }

  metadata = {
    "ssh_authorized_keys" = tls_private_key.ssh.public_key_openssh,
    "user_data"           = module.oci_setup.template_cloudinit_config
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

  freeform_tags = {
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
