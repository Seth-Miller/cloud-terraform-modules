resource "oci_kms_vault" "id" {
  compartment_id = var.compartment
  display_name   = "${var.project_name}_git-secret"
  vault_type     = "DEFAULT"

  freeform_tags = {
    Name    = "${var.project_name}_git-secret"
    Project = var.project_name
  }
}

resource "time_sleep" "wait_for_vault" {
  depends_on      = [oci_kms_vault.id]
  create_duration = "15s"
}

resource "oci_kms_key" "id" {
  depends_on      = [time_sleep.wait_for_vault]
  compartment_id  = var.compartment
  display_name    = "${var.project_name}_git-secret"
  protection_mode = "SOFTWARE"
  key_shape {
    algorithm = "AES"
    length    = 32
  }
  management_endpoint = oci_kms_vault.id.management_endpoint

  freeform_tags = {
    Name    = "${var.project_name}_git-secret"
    Project = var.project_name
  }
}

resource "oci_vault_secret" "id" {
  compartment_id = var.compartment
  secret_name    = "${var.project_name}_git-secret"
  key_id         = oci_kms_key.id.id
  vault_id       = oci_kms_vault.id.id
  secret_content {
    content_type = "BASE64"
    content      = base64encode(jsonencode(var.git_secret))
  }

  freeform_tags = {
    Name    = "${var.project_name}_git-secret"
    Project = var.project_name
  }

  lifecycle {
    ignore_changes = [
      key_id,
    ]
  }
}

output "secret_id" {
  value = oci_vault_secret.id.id
}
