data "external" "vault_ocid" {
  program = ["sh", "${path.module}/get_existing_vault.sh"]

  query = {
    root_compartment_ocid = var.root_compartment_ocid
    vault_name = "${var.project_name}_git-secret"
  }
}

module "oci_load_git_secret" {
  source = "../../modules/oci_load_git_secret"

  project_name = var.project_name
  region       = var.region
  compartment  = var.root_compartment_ocid
  vault_ocid  = data.external.vault_ocid.result.vault_ocid
  git_secret   = local.git_secret
}