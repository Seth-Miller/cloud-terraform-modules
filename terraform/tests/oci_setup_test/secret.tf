locals {
  target_vault_id = [
    for vault in data.oci_kms_vaults.vault.vaults : 
    vault.id if vault.display_name == var.vault_name
    && vault.state == "ACTIVE"
  ][0]
  target_secret_id = data.oci_vault_secrets.secret.secrets[0].id
}

data "oci_kms_vaults" "vault" {
  compartment_id = var.parent_compartment_ocid
}

data "oci_vault_secrets" "secret" {
  compartment_id = var.parent_compartment_ocid
  vault_id       = local.target_vault_id
  name           = var.secret_name
  state          = "ACTIVE"
} 
