resource "oci_core_vcn" "lab" {
  compartment_id = oci_identity_compartment.compartment.id
  cidr_blocks    = var.vcn_cidr_blocks
  display_name   = "${var.project_name}_vcn"
  dns_label      = replace("${var.project_name}", "-", "")

  freeform_tags = {
    Name    = "${var.project_name}_vcn"
    Project = var.project_name
  }
}

resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = oci_core_vcn.lab.default_security_list_id
  display_name               = "${var.project_name}_security_list_public"

  dynamic "ingress_security_rules" {
    iterator = port
    for_each = [22]

    content {
      protocol = 6
      source   = "0.0.0.0/0"
      tcp_options {
        min = port.value
        max = port.value
      }
    }
  }

  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"
    icmp_options {
      type = 3
      code = 4
    }
  }

  dynamic "ingress_security_rules" {
    iterator = cidr
    for_each = var.vcn_cidr_blocks

    content {
      protocol = 1
      source   = cidr.value
      icmp_options {
        type = 3
      }
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  freeform_tags = {
    Name    = "${var.project_name}_security_list_public"
    Project = var.project_name
  }
}

resource "oci_core_security_list" "security_list_private_subnet" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "${var.project_name}_security_list_private"

  dynamic "ingress_security_rules" {
    iterator = port
    for_each = [22]

    content {
      protocol = 6
      source   = "0.0.0.0/0"
      tcp_options {
        min = port.value
        max = port.value
      }
    }
  }

  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"
    icmp_options {
      type = 3
      code = 4
    }
  }

  dynamic "ingress_security_rules" {
    iterator = cidr
    for_each = var.vcn_cidr_blocks
    content {
      protocol = 1
      source   = cidr.value
      icmp_options {
        type = 3
      }
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  freeform_tags = {
    Name    = "${var.project_name}_security_list_private"
    Project = var.project_name
  }
}

resource "oci_core_subnet" "lab_public" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "${var.project_name}_subnet_public"
  dns_label      = "public"

  ipv4cidr_blocks            = var.public_cidr_blocks
  prohibit_public_ip_on_vnic = false

  freeform_tags = {
    Name    = "${var.project_name}_subnet_public"
    Project = var.project_name
  }
}

resource "oci_core_subnet" "lab_private" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "${var.project_name}_subnet_private"
  dns_label      = "private"

  ipv4cidr_blocks            = var.private_cidr_blocks
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.security_list_private_subnet.id]

  freeform_tags = {
    Name    = "${var.project_name}_subnet_private"
    Project = var.project_name
  }
}

resource "oci_core_nat_gateway" "lab" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "${var.project_name}_nat_gateway"

  freeform_tags = {
    Name    = "${var.project_name}_nat_gateway"
    Project = var.project_name
  }
}

resource "oci_core_internet_gateway" "lab" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.lab.id
  enabled        = true
  display_name   = "${var.project_name}_internet_gateway"

  freeform_tags = {
    Name    = "${var.project_name}_internet_gateway"
    Project = var.project_name
  }
}

resource "oci_core_default_route_table" "lab" {
  manage_default_resource_id = oci_core_vcn.lab.default_route_table_id
  display_name               = "${var.project_name}_route_table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.lab.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = {
    Name    = "${var.project_name}_route_table"
    Project = var.project_name
  }
}
