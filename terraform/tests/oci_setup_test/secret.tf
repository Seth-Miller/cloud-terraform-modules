locals {
  #target_vault_id = [
  #  for vault in data.oci_kms_vaults.vault.vaults : 
  #  vault.id if vault.display_name == var.vault_name
  #  && vault.state == "ACTIVE"
  #][0]
  target_secret_id = values(data.oci_vault_secrets.secret)[0].secrets[0].id
}

data "oci_kms_vaults" "vault" {
  compartment_id = var.parent_compartment_ocid
}

data "oci_vault_secrets" "secret" {
  for_each = {
    for vault in data.oci_kms_vaults.vault.vaults : vault.id => vault
    if vault.display_name == var.vault_name
    && vault.state == "ACTIVE"
  }

  compartment_id = var.parent_compartment_ocid
  vault_id       = each.key
  name           = var.secret_name
  state          = "ACTIVE"
} 
