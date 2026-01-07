data "oci_kms_vaults" "vault" {
  compartment_id = var.parent_compartment_ocid
}

locals {
  target_vault_id = [
    for vault in data.oci_kms_vaults.vault.vaults : 
    vault.id if vault.display_name == var.vault_name
    and vault.state == "ACTIVE"
  ][0]
}

data "oci_vault_secrets" "secret" {
  compartment_id = var.parent_compartment_ocid
  vault_id       = local.target_vault_id
  name           = var.secret_name
  state          = "ACTIVE"
} 