resource "oci_kms_vault" "id" {
  compartment_id = oci_identity_compartment.id.id
  display_name   = local.vault_display_name
  vault_type     = "DEFAULT"
}

resource "time_sleep" "wait_for_vault" {
  depends_on      = [oci_kms_vault.id]
  create_duration = "15s"
}

resource "oci_kms_key" "id" {
  depends_on = [time_sleep.wait_for_vault]
  compartment_id  = oci_identity_compartment.id.id
  display_name    = local.key_display_name
  protection_mode = "SOFTWARE"
  key_shape {
    algorithm = "AES"
    length    = 32
  }
  management_endpoint = oci_kms_vault.id.management_endpoint
}

resource "oci_vault_secret" "id" {
  compartment_id = oci_identity_compartment.id.id
  key_id         = oci_kms_key.id.id
  secret_name    = local.secret_name
  vault_id       = oci_kms_vault.id.id
  secret_content {
    content_type = "BASE64"
    content      = base64encode(local.secret_content)
  }
}
