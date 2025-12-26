locals {
  compartment_name               = "management"
  parent_compartment_ocid        = "ocid1.tenancy.oc1..aaaaaaaagzjw43srbqtlam5ayvehor5x6nm4hcybw6zpz5o2ff62braq3o3q"
  secret_content                 = "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"
  region                         = "us-chicago-1"
  availability_domain            = "WVjn:US-CHICAGO-1-AD-1"
  subnet_public_dns_label        = "pub"
  subnet_private_dns_label       = "priv"
  vcn_dns_label                  = local.compartment_name
  vcn_display_name               = "${local.compartment_name}_vcn"
  compartment_description        = "${local.compartment_name} compartment"
  dynamic_group_name             = "${local.compartment_name}_dynamic_group"
  dynamic_group_description             = "${local.compartment_name}_dynamic_group"
  policy_name                    = "${local.compartment_name}_policy"
  policy_description                    = "${local.compartment_name}_policy"
  vault_display_name             = "${local.compartment_name}_vault"
  key_display_name               = "${local.compartment_name}_key"
  secret_name                    = "${local.compartment_name}_git_secret"
  vcn_cidr_blocks                = ["172.17.0.0/16", ]
  subnet_ipv4cidr_blocks_public  = ["172.17.0.0/24", ]
  subnet_ipv4cidr_blocks_private = ["172.17.1.0/24", ]
  ingress_ports                  = [22, ]

  vm_shape = "VM.Standard.A1.Flex"
  vm_image = "ocid1.image.oc1.us-chicago-1.aaaaaaaasrbvw2qh25ewu3gg2div6bkwvqdi2oilwxirhic3qa5tzzxrcdwa"
  ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7cFAWlLDaXyApzSMOA4lnH/JUxHKNLGaNsoDi7Zb7ZgcSiKFEXYULyrfddbrGg8ZvpXEbwhStxary41WQZLoWgz+zMSwKko54W+Ltf9qsGYSdrkhxYR3KRpnuJ+l07vGaEZ2SEcv7FuPomCfqxuhX6N82g4syqgGbbtZHr6nttmfVw5U1gHoeQScB3CrSisWwPNEVJbSzZPviS2XhsXbZyT/+3eYeLrcGGXkFSPP9+ngk3jBT68bxpR+LmuW8ZlV0aQzX1LXto3Pmg2E79EvVVtLPW1BsGn5j9udh5P+9KnrRpS7PuxlgBCZaG5xrnlaulGI73Nta21nk9aph89OP ssh-key-2025-09-08"

  vms = {
    "${local.compartment_name}" = {}
  }
}
