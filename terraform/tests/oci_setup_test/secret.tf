data "oci_vault_secrets" "secret" {
  compartment_id = var.parent_compartment_ocid
  name           = var.secret_name
  state          = "ACTIVE"
} 