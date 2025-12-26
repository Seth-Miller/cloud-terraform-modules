
resource "oci_identity_compartment" "id" {
  compartment_id = local.parent_compartment_ocid
  name           = local.compartment_name
  description    = local.compartment_description
}

resource "oci_core_vcn" "lab" {
  compartment_id = oci_identity_compartment.id.id
  cidr_blocks    = local.vcn_cidr_blocks
  display_name   = local.vcn_display_name
  dns_label      = local.vcn_dns_label
}

resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = oci_core_vcn.lab.default_security_list_id

  dynamic "ingress_security_rules" {
    iterator = port
    for_each = local.ingress_ports

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
    for_each = local.vcn_cidr_blocks

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
}

resource "oci_core_security_list" "security_list_private_subnet" {
  compartment_id = oci_identity_compartment.id.id
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "security list for private subnet-${local.vcn_display_name}"

  dynamic "ingress_security_rules" {
    iterator = port
    for_each = local.ingress_ports

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
    for_each = local.vcn_cidr_blocks
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
}

resource "oci_core_subnet" "lab_public" {
  compartment_id = oci_identity_compartment.id.id
  vcn_id         = oci_core_vcn.lab.id

  dns_label                  = local.subnet_public_dns_label
  ipv4cidr_blocks            = local.subnet_ipv4cidr_blocks_public
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "lab_private" {
  compartment_id = oci_identity_compartment.id.id
  vcn_id         = oci_core_vcn.lab.id

  dns_label                  = local.subnet_private_dns_label
  ipv4cidr_blocks            = local.subnet_ipv4cidr_blocks_private
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.security_list_private_subnet.id]

}

resource "oci_core_nat_gateway" "lab" {
  compartment_id = oci_identity_compartment.id.id
  vcn_id         = oci_core_vcn.lab.id
}

resource "oci_core_internet_gateway" "lab" {
  compartment_id = oci_identity_compartment.id.id
  vcn_id         = oci_core_vcn.lab.id
  enabled        = true
}

resource "oci_core_default_route_table" "lab" {
  manage_default_resource_id = oci_core_vcn.lab.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.lab.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}
